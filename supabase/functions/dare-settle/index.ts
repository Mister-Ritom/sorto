// supabase/functions/dare-settle/index.ts
// Edge Function: dare-settle
// Poster approves or rejects a submission, triggering coin settlement.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

const PLATFORM_FEE_PCT = 0.20;
const BAD_FAITH_PENALTY_PCT = 0.10; // Applied if poster rejection is disputed and overturned

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

    const { dare_id, submission_id, verdict, reason } = await req.json();
    if (!dare_id || !submission_id || !verdict) throw new Error('Missing required fields');
    if (!['approved', 'rejected'].includes(verdict)) throw new Error('verdict must be approved or rejected');
    if (verdict === 'rejected' && (!reason || reason.trim().length < 20)) {
      throw new Error('Rejection requires a reason of at least 20 characters');
    }

    // Load dare
    const { data: dare, error: dareErr } = await supabase
      .from('dares')
      .select('*')
      .eq('id', dare_id)
      .single();
    if (dareErr || !dare) throw new Error('Dare not found');
    if (dare.poster_id !== user.id) throw new Error('Only the poster can settle this dare');

    // Load submission
    const { data: submission, error: subErr } = await supabase
      .from('dare_submissions')
      .select('*')
      .eq('id', submission_id)
      .single();
    if (subErr || !submission) throw new Error('Submission not found');
    if (submission.dare_id !== dare_id) throw new Error('Submission does not belong to this dare');
    if (submission.poster_verdict) throw new Error('This submission has already been settled');

    const bountyAmount = dare.bounty_amount;
    const platformFee = Math.round(bountyAmount * PLATFORM_FEE_PCT);
    const performerPayout = bountyAmount - platformFee;

    if (verdict === 'approved') {
      // ── Pay the performer ──────────────────────────────────────────────────
      // Release from escrow, pay performer, record platform fee
      await supabase.rpc('dare_payout', {
        p_dare_id: dare_id,
        p_performer_id: submission.performer_id,
        p_poster_id: dare.poster_id,
        p_payout_amount: performerPayout,
        p_platform_fee: platformFee,
        p_bounty: bountyAmount,
      });

      // Update submission
      await supabase.from('dare_submissions').update({
        poster_verdict: 'approved',
        payout_amount: performerPayout,
        settled_at: new Date().toISOString(),
      }).eq('id', submission_id);

      // Update dare
      await supabase.from('dares').update({
        status: 'completed',
        winner_performer_id: submission.performer_id,
        updated_at: new Date().toISOString(),
      }).eq('id', dare_id);

      // Update performer profile stats
      await supabase.from('profiles').update({
        total_dares_completed: supabase.rpc('increment_column', { p_id: submission.performer_id, p_col: 'total_dares_completed' }),
        total_earned_coins: supabase.rpc('increment_column_amount', { p_id: submission.performer_id, p_col: 'total_earned_coins', p_amount: performerPayout }),
      }).eq('id', submission.performer_id);

      // Notify performer
      await supabase.from('notifications').insert({
        user_id: submission.performer_id,
        type: 'dare_approved',
        title: '✅ Dare approved! Coins incoming!',
        body: `Your proof was approved. ${performerPayout} coins added to your wallet.`,
        dare_id,
      });

      // Notify poster
      await supabase.from('notifications').insert({
        user_id: user.id,
        type: 'dare_settled',
        title: '✅ Dare settled',
        body: `You approved the proof for "${dare.title}". Coins settled.`,
        dare_id,
      });
    } else {
      // ── Reject ────────────────────────────────────────────────────────────
      await supabase.from('dare_submissions').update({
        poster_verdict: 'rejected',
        poster_note: reason,
        settled_at: new Date().toISOString(),
      }).eq('id', submission_id);

      // For solo mode: unlock dare back to open
      if (dare.dare_mode === 'solo') {
        await supabase.from('dares').update({
          status: 'open',
          performer_id: null,
          updated_at: new Date().toISOString(),
        }).eq('id', dare_id);
      }

      // Notify performer
      await supabase.from('notifications').insert({
        user_id: submission.performer_id,
        type: 'dare_rejected',
        title: '❌ Proof rejected',
        body: `Reason: ${reason}. You may contest this decision.`,
        dare_id,
      });
    }

    return new Response(
      JSON.stringify({ success: true, verdict }),
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
