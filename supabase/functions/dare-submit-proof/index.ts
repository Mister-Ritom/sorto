// supabase/functions/dare-submit-proof/index.ts
// Edge Function: dare-submit-proof
// Creates a dare_submission and triggers AI moderation.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

const AUTO_REJECT_HARM_THRESHOLD = 0.90;
const WARNING_THRESHOLD = 0.80;

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

    const { dare_id, video_path, proof_text } = await req.json();
    if (!dare_id || !video_path) throw new Error('dare_id and video_path required');

    // Load dare
    const { data: dare, error: dareErr } = await supabase
      .from('dares')
      .select('*')
      .eq('id', dare_id)
      .single();
    if (dareErr || !dare) throw new Error('Dare not found');
    if (dare.status === 'completed' || dare.status === 'cancelled') {
      throw new Error('Dare is no longer accepting submissions');
    }
    // For solo mode: only the claimed performer can submit
    if (dare.dare_mode === 'solo' && dare.performer_id !== user.id) {
      throw new Error('This solo dare is claimed by another performer');
    }

    // Generate signed URL for storage path
    const { data: signedUrl } = await supabase.storage
      .from('proof-videos')
      .createSignedUrl(video_path, 60 * 60); // 1-hour URL for AI processing

    // ── AI Moderation ─────────────────────────────────────────────────────────
    // Call the AI moderation function (Gemini Flash via Google API)
    let aiVerdict: string = 'pending';
    let aiConfidence = 0.0;
    let aiHarmScore = 0.0;
    let aiRawResponse: object = {};

    try {
      const geminiKey = Deno.env.get('GEMINI_API_KEY');
      if (geminiKey && signedUrl?.signedUrl) {
        const moderationPrompt = `You are a content moderation AI for a dare platform called Sorto.
The dare requirement is: "${dare.title}". ${dare.description}

Review this video URL: ${signedUrl.signedUrl}

Respond with JSON:
{
  "verdict": "approved" | "rejected" | "escalated",
  "confidence": 0.00-1.00,
  "harm_score": 0.00-1.00,
  "completed_dare": true|false,
  "reason": "brief reason"
}

Auto-reject if: nudity, extreme violence, illegal activity, harm to others. harm_score > 0.90 = reject.`;

        const geminiRes = await fetch(
          `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${geminiKey}`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [{ parts: [{ text: moderationPrompt }] }],
              generationConfig: { response_mime_type: 'application/json' }
            }),
          }
        );
        const geminiData = await geminiRes.json();
        const rawText = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text ?? '{}';
        const parsed = JSON.parse(rawText);
        aiVerdict = parsed.verdict ?? 'pending';
        aiConfidence = parsed.confidence ?? 0;
        aiHarmScore = parsed.harm_score ?? 0;
        aiRawResponse = parsed;

        // Auto-reject on high harm
        if (aiHarmScore >= AUTO_REJECT_HARM_THRESHOLD) {
          aiVerdict = 'rejected';
        }
      }
    } catch (_aiErr) {
      // AI moderation failure — escalate to human
      aiVerdict = 'escalated';
      aiConfidence = 0;
    }

    // ── Create submission ─────────────────────────────────────────────────────
    const { data: submission, error: subErr } = await supabase
      .from('dare_submissions')
      .insert({
        dare_id,
        performer_id: user.id,
        proof_video_url: video_path,
        proof_text: proof_text ?? null,
        ai_verdict: aiVerdict,
        ai_confidence: aiConfidence,
        ai_harm_score: aiHarmScore,
        ai_raw_response: aiRawResponse,
      })
      .select()
      .single();
    if (subErr) throw new Error(`Submission insert failed: ${subErr.message}`);

    // Update dare status to under_review (for solo)
    if (dare.dare_mode === 'solo') {
      await supabase
        .from('dares')
        .update({ status: 'under_review', updated_at: new Date().toISOString() })
        .eq('id', dare_id);
    }

    // ── If AI auto-rejected ────────────────────────────────────────────────────
    if (aiVerdict === 'rejected') {
      // Refund escrow to poster
      await supabase.rpc('dare_refund_escrow', { p_dare_id: dare_id });

      await supabase.from('notifications').insert([
        {
          user_id: user.id,
          type: 'dare_rejected',
          title: '❌ Submission rejected',
          body: `Our AI moderation rejected your submission for "${dare.title}".`,
          dare_id,
        },
      ]);
    } else {
      // Notify poster to review (or that proof came in for open modes)
      await supabase.from('notifications').insert([
        {
          user_id: dare.poster_id,
          type: 'proof_submitted',
          title: '📹 Proof submitted!',
          body: `Someone submitted proof for your dare "${dare.title}". ${aiVerdict === 'escalated' ? '(Flagged for review)' : 'Review and approve/reject.'}`,
          dare_id,
        },
        {
          user_id: user.id,
          type: 'proof_submitted',
          title: '📹 Proof uploaded!',
          body: `Your proof for "${dare.title}" is under review.`,
          dare_id,
        },
      ]);
    }

    return new Response(
      JSON.stringify({ submission, ai_verdict: aiVerdict }),
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
