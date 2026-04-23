// supabase/functions/performer-post-fund/index.ts
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

    const { post_id } = await req.json();
    if (!post_id) throw new Error('post_id required');

    // 1. Get the post
    const { data: post, error: postErr } = await supabase
      .from('performer_posts')
      .select('*')
      .eq('id', post_id)
      .single();
    if (postErr || !post) throw new Error('Post not found');
    if (post.status !== 'open') throw new Error('Post is no longer open');
    if (post.performer_id === user.id) throw new Error('Cannot fund your own post');

    // 2. Atomic Transaction:
    // a. Escrow coins from funder
    await supabase.rpc('dare_escrow_coins', { p_user_id: user.id, p_amount: post.asking_price });

    // b. Create a Locked Dare
    const { data: dare, error: dareErr } = await supabase
      .from('dares')
      .insert({
        poster_id: user.id,
        performer_id: post.performer_id,
        title: `AD: ${post.title}`,
        description: post.description,
        category: post.category,
        bounty_amount: post.asking_price,
        status: 'locked', // Automatically claimed
        dare_mode: 'solo',
        expires_at: post.deadline,
      })
      .select()
      .single();

    if (dareErr) throw new Error(`Dare creation failed: ${dareErr.message}`);

    // c. Update the Performer Post
    await supabase
      .from('performer_posts')
      .update({ status: 'funded', funder_id: user.id, updated_at: new Date().toISOString() })
      .eq('id', post_id);

    // d. Transaction record
    await supabase.from('transactions').insert({
      user_id: user.id,
      dare_id: dare.id,
      type: 'dare_lock',
      amount: post.asking_price,
      direction: 'debit',
      metadata: { post_title: post.title },
    });

    // e. Notifications
    // To performer
    await supabase.from('notifications').insert({
      user_id: post.performer_id,
      type: 'dare_funded',
      title: '🎬 Post funded!',
      body: `Someone funded your post "${post.title}". Prove it now!`,
      dare_id: dare.id,
    });

    // To funder
    await supabase.from('notifications').insert({
      user_id: user.id,
      type: 'dare_posted',
      title: '✅ Dare created',
      body: `You funded @${post.performer_id}'s post. Daring them now!`,
      dare_id: dare.id,
    });

    return new Response(
      JSON.stringify({ dare_id: dare.id }),
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
