// supabase/functions/dare-claim/index.ts
// Edge Function: dare-claim
// Claims a SOLO dare for a performer (locks it to them).

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

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

    const { dare_id } = await req.json();
    if (!dare_id) throw new Error('dare_id required');

    // Load dare
    const { data: dare, error: dareErr } = await supabase
      .from('dares')
      .select('*')
      .eq('id', dare_id)
      .single();
    if (dareErr || !dare) throw new Error('Dare not found');
    if (dare.dare_mode !== 'solo') throw new Error('Only solo dares can be claimed');
    if (dare.status !== 'open') throw new Error('Dare is no longer open');
    if (dare.poster_id === user.id) throw new Error('You cannot claim your own dare');

    // Lock the dare
    const { error: updateErr } = await supabase
      .from('dares')
      .update({ status: 'locked', performer_id: user.id, updated_at: new Date().toISOString() })
      .eq('id', dare_id)
      .eq('status', 'open'); // optimistic concurrency check
    if (updateErr) throw new Error('Claim failed (race condition or already claimed)');

    // Notify poster
    const { data: performerProfile } = await supabase
      .from('profiles')
      .select('username')
      .eq('id', user.id)
      .single();

    await supabase.from('notifications').insert({
      user_id: dare.poster_id,
      type: 'dare_claimed',
      title: '🎯 Dare claimed!',
      body: `@${performerProfile?.username ?? 'Someone'} claimed your dare "${dare.title}".`,
      dare_id,
    });

    return new Response(
      JSON.stringify({ success: true }),
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
