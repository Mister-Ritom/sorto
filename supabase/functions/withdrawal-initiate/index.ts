// supabase/functions/withdrawal-initiate/index.ts
// Edge Function: withdrawal-initiate
// Initiates a withdrawal: validates, locks coins, creates request.
// Actual payout is handled by a separate Razorpay webhook processor.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

const MIN_WITHDRAWAL_COINS = 100;

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { persistSession: false } }
    );

    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    const { data: { user }, error: authErr } = await supabase.auth.getUser(token!);
    if (authErr || !user) throw new Error('Unauthorized');

    const { coin_amount, upi_id } = await req.json();
    if (!coin_amount || !upi_id) throw new Error('coin_amount and upi_id required');
    if (coin_amount < MIN_WITHDRAWAL_COINS) {
      throw new Error(`Minimum withdrawal is ${MIN_WITHDRAWAL_COINS} coins`);
    }
    if (!upi_id.includes('@')) throw new Error('Invalid UPI ID format');

    // Check wallet
    const { data: wallet, error: walletErr } = await supabase
      .from('wallets')
      .select('coin_balance')
      .eq('user_id', user.id)
      .single();
    if (walletErr || !wallet) throw new Error('Wallet not found');
    if (wallet.coin_balance < coin_amount) throw new Error('Insufficient balance');

    // Check for pending withdrawals
    const { count: pendingCount } = await supabase
      .from('withdrawal_requests')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .eq('status', 'pending');
    if (pendingCount && pendingCount > 0) {
      throw new Error('You already have a pending withdrawal request');
    }

    // Lock coins (debit from coin_balance, credit to pending_withdrawal)
    await supabase.rpc('withdrawal_lock_coins', {
      p_user_id: user.id,
      p_amount: coin_amount,
    });

    // Create withdrawal request
    const { data: withdrawalReq, error: reqErr } = await supabase
      .from('withdrawal_requests')
      .insert({
        user_id: user.id,
        coin_amount,
        inr_amount: coin_amount, // 1:1 rate
        upi_id: upi_id.trim().toLowerCase(),
        status: 'pending',
      })
      .select()
      .single();
    if (reqErr) throw new Error(`Withdrawal request failed: ${reqErr.message}`);

    // Transaction record
    await supabase.from('transactions').insert({
      user_id: user.id,
      type: 'withdrawal_request',
      amount: coin_amount,
      direction: 'debit',
      metadata: { upi_id, withdrawal_id: withdrawalReq.id },
    });

    // Notify user
    await supabase.from('notifications').insert({
      user_id: user.id,
      type: 'withdrawal_complete', // optimistic
      title: '🏦 Withdrawal requested',
      body: `₹${coin_amount} withdrawal to ${upi_id} is being processed. Arrives in 1-2 business days.`,
    });

    return new Response(
      JSON.stringify({ success: true, request_id: withdrawalReq.id }),
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
