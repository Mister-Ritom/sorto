// supabase/functions/create-razorpay-order/index.ts
//
// Creates a Razorpay order server-side.
// Receives: { coins: number, amount_inr: number }  (1 coin = ₹1)
// Returns:  { order_id, amount, currency }
// amount returned is in paise so the Flutter checkout widget can use it directly.

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

    // ── GET PRICES PREVIEW MODE ──────────────────────────────────────────────
    if (body.get_prices) {
      const countryCode = body.country_code || 'IN';
      let currency = 'INR';
      let rate = 1.0;

      if (countryCode !== 'IN') {
        const currencyMap: Record<string, string> = {
          'US': 'USD', 'GB': 'GBP', 'EU': 'EUR', 'CA': 'CAD', 'AU': 'AUD', 'AE': 'AED'
        };
        currency = currencyMap[countryCode] || 'USD';
        try {
          const rateRes = await fetch(`https://api.exchangerate-api.com/v4/latest/INR`);
          const rates = (await rateRes.json()).rates;
          rate = rates[currency] || rates['USD'];
        } catch (e) {
          rate = 0.012; // fallback
        }
      }

      const tiers = [100, 300, 500, 1000, 2000, 5000].map(coins => {
        const amount = Number((coins * rate).toFixed(2));
        return { coins, amount, currency };
      });

      return new Response(JSON.stringify({ tiers }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    const coins: number = body.coins;
    const countryCode: string = body.country_code || 'IN';

    if (!coins || coins <= 0) {
      throw new Error('Invalid coins');
    }

    // ── Determine Currency ───────────────────────────────────────────────────
    let currency = 'INR';
    if (countryCode !== 'IN') {
      // Map common countries, default others to USD
      const currencyMap: Record<string, string> = {
        'US': 'USD', 'GB': 'GBP', 'EU': 'EUR', 'CA': 'CAD', 'AU': 'AUD', 'AE': 'AED'
      };
      currency = currencyMap[countryCode] || 'USD';
    }

    // ── Calculate Amount with Exchange Rate ──────────────────────────────────
    // Base: 100 coins = 100 INR
    let finalAmountPaise = coins * 100; // Default INR paise

    if (currency !== 'INR') {
      try {
        const rateRes = await fetch(`https://api.exchangerate-api.com/v4/latest/INR`);
        const rates = (await rateRes.json()).rates;
        const rate = rates[currency] || rates['USD'];
        
        // Convert INR to Native Currency
        // e.g. 100 INR * 0.012 = 1.20 USD
        const nativeAmount = (coins * rate);
        finalAmountPaise = Math.round(nativeAmount * 100); 
      } catch (e) {
        console.error('Exchange rate fetch failed, falling back to approximate USD', e);
        // Fallback: ~0.012 USD per 1 INR
        finalAmountPaise = Math.round(coins * 0.012 * 100);
        currency = 'USD';
      }
    }

    // ── Razorpay keys ────────────────────────────────────────────────────────
    const keyId = Deno.env.get('RAZORPAY_KEY_ID');
    const keySecret = Deno.env.get('RAZORPAY_KEY_SECRET');
    if (!keyId || !keySecret) throw new Error('Razorpay keys not configured');

    // ── Create Razorpay order ────────────────────────────────────────────────
    const receipt = `sorto_${user.id.slice(0, 8)}_${coins}_${Date.now()}`;

    const rzpRes = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${btoa(`${keyId}:${keySecret}`)}`,
      },
      body: JSON.stringify({
        amount: finalAmountPaise,
        currency: currency,
        receipt,
        notes: {
          user_id: user.id,
          coins: String(coins),
          original_currency: 'INR',
          original_amount: String(coins),
        },
      }),
    });

    if (!rzpRes.ok) {
      const errBody = await rzpRes.text();
      throw new Error(`Razorpay order creation failed: ${errBody}`);
    }

    const order = await rzpRes.json();

    return new Response(
      JSON.stringify({
        order_id: order.id,
        amount: order.amount,   // paise — returned for checkout widget
        currency: order.currency,
      }),
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
