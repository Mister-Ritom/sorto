// supabase/functions/verify-razorpay-payment/index.ts
//
// Verifies Razorpay payment signature (HMAC SHA-256) and credits coins.
// Receives: { order_id, payment_id, signature, coins }
// Returns:  { success: true } or 401 if signature invalid.
//
// Iron Rule: Coins are ONLY credited here after server-side verification.
// The Flutter app never self-reports payment success.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // ── Auth ─────────────────────────────────────────────────────────────────
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { persistSession: false } },
    );

    const token = req.headers.get('Authorization')?.replace('Bearer ', '');
    const { data: { user }, error: authErr } = await supabase.auth.getUser(token!);
    if (authErr || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // ── Validate body ────────────────────────────────────────────────────────
    const body = await req.json();
    const { order_id, payment_id, signature, coins } = body;

    if (!order_id || !payment_id || !signature || !coins) {
      throw new Error('Missing required fields');
    }

    const validCoins = [100, 300, 500, 1000, 2000, 5000];
    if (!validCoins.includes(Number(coins))) {
      throw new Error(`Invalid coin tier: ${coins}`);
    }

    // ── Signature verification ────────────────────────────────────────────────
    // Razorpay signature = HMAC-SHA256(order_id + "|" + payment_id, key_secret)
    const keySecret = Deno.env.get('RAZORPAY_KEY_SECRET');
    if (!keySecret) throw new Error('Razorpay secret not configured');

    const encoder = new TextEncoder();
    const message = `${order_id}|${payment_id}`;

    const cryptoKey = await crypto.subtle.importKey(
      'raw',
      encoder.encode(keySecret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['sign'],
    );

    const sigBytes = await crypto.subtle.sign('HMAC', cryptoKey, encoder.encode(message));
    const expectedSignature = Array.from(new Uint8Array(sigBytes))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');

    if (expectedSignature !== signature) {
      return new Response(
        JSON.stringify({ error: 'Invalid payment signature' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // ── Idempotency check ─────────────────────────────────────────────────────
    // Prevent double-crediting if the webhook and Flutter both call this.
    const { data: existing } = await supabase
      .from('transactions')
      .select('id')
      .eq('metadata->>razorpay_payment_id', payment_id)
      .maybeSingle();

    if (existing) {
      // Already processed — return success without double-crediting
      return new Response(
        JSON.stringify({ success: true, already_processed: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // ── Credit coins ──────────────────────────────────────────────────────────
    const coinAmount = Number(coins);

    const { error: walletErr } = await supabase.rpc('add_coins', {
      p_user_id: user.id,
      p_amount: coinAmount,
    });

    if (walletErr) throw new Error(`Wallet credit failed: ${walletErr.message}`);

    // ── Transaction record ────────────────────────────────────────────────────
    const { error: txnErr } = await supabase.from('transactions').insert({
      user_id: user.id,
      type: 'topup_web',
      amount: coinAmount,
      direction: 'credit',
      metadata: {
        note: `Purchased ${coinAmount} Sorto Coins via Razorpay`,
        razorpay_order_id: order_id,
        razorpay_payment_id: payment_id,
        source: 'razorpay',
      },
    });

    if (txnErr) throw new Error(`Transaction record failed: ${txnErr.message}`);

    return new Response(
      JSON.stringify({ success: true, coins_added: coinAmount }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    return new Response(
      JSON.stringify({ error: message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
