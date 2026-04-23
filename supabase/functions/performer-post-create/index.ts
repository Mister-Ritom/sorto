// supabase/functions/performer-post-create/index.ts
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

    const { title, description, category, asking_price, deadline } = await req.json();
    if (!title || !description || !category || !asking_price) {
      throw new Error('Missing fields');
    }

    const { data: post, error: postErr } = await supabase
      .from('performer_posts')
      .insert({
        performer_id: user.id,
        title,
        description,
        category,
        asking_price,
        deadline,
        status: 'open',
      })
      .select()
      .single();

    if (postErr) throw new Error(postErr.message);

    return new Response(
      JSON.stringify({ post_id: post.id }),
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
