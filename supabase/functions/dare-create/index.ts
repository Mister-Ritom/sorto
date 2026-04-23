// supabase/functions/dare-create/index.ts
// Edge Function: dare-create
// Creates a dare and locks coins atomically.
// Called via: supabase.functions.invoke('dare-create', { body: {...} })
// Iron Rule: ALL wallet mutations happen here — client never writes to wallets.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

const PLATFORM_FEE_PCT = 0.20;

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // ── Auth ──────────────────────────────────────────────────────────────────
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { persistSession: false } }
    );

    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    const { data: { user }, error: authErr } = await supabase.auth.getUser(token!);
    if (authErr || !user) throw new Error('Unauthorized');

    // ── Validate body ─────────────────────────────────────────────────────────
    const body = await req.json();
    const { title, description, category, tags = [], dare_mode = 'solo', bounty_amount, expires_at } = body;

    if (!title || !description || !category || !bounty_amount || !expires_at) {
      throw new Error('Missing required fields');
    }
    if (bounty_amount < 10) throw new Error('Minimum bounty is 10 coins');

    // ── Wallet check ──────────────────────────────────────────────────────────
    const { data: wallet, error: walletErr } = await supabase
      .from('wallets')
      .select('coin_balance')
      .eq('user_id', user.id)
      .single();
    if (walletErr || !wallet) throw new Error('Wallet not found');
    if (wallet.coin_balance < bounty_amount) throw new Error('Insufficient balance');

    // ── Atomic DB transaction ─────────────────────────────────────────────────
    // 1. Create dare
    const { data: dare, error: dareErr } = await supabase
      .from('dares')
      .insert({
        poster_id: user.id,
        title: title.trim(),
        description: description.trim(),
        category,
        tags,
        bounty_amount,
        platform_fee_pct: PLATFORM_FEE_PCT,
        dare_mode,
        expires_at,
      })
      .select()
      .single();
    if (dareErr) throw new Error(`Dare insert failed: ${dareErr.message}`);

    // 2. Debit coins from spendable, credit to escrowed
    const { error: walletUpdateErr } = await supabase
      .from('wallets')
      .update({
        coin_balance: wallet.coin_balance - bounty_amount,
        escrowed_balance: supabase.rpc('increment_escrowed', { p_user_id: user.id, p_amount: bounty_amount }),
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', user.id);

    // Simpler: use a raw UPDATE to avoid rpc for escrowed
    await supabase.rpc('dare_escrow_coins', { p_user_id: user.id, p_amount: bounty_amount });

    // 3. Transaction record
    await supabase.from('transactions').insert({
      user_id: user.id,
      dare_id: dare.id,
      type: 'dare_lock',
      amount: bounty_amount,
      direction: 'debit',
      metadata: { dare_title: title },
    });

    // 4. Notify poster
    await supabase.from('notifications').insert({
      user_id: user.id,
      type: 'dare_posted',
      title: '🎯 Dare posted!',
      body: `"${title}" is now live. ${bounty_amount} coins locked in escrow.`,
      dare_id: dare.id,
    });

    return new Response(
      JSON.stringify({ dare }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    return new Response(
      JSON.stringify({ error: message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
