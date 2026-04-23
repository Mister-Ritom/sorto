// lib/features/performer_posts/performer_posts_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/models/performer_post.dart';

// ─── ALL POSTS FEED ───────────────────────────────────────────────────────────
final performerPostsFeedProvider =
    FutureProvider<List<PerformerPost>>((ref) async {
  return ref.read(supabaseServiceProvider).getPerformerPosts(
      status: 'open', limit: 30);
});

// ─── SINGLE POST ──────────────────────────────────────────────────────────────
final performerPostDetailProvider =
    FutureProvider.family<PerformerPost?, String>((ref, postId) async {
  return ref.read(supabaseServiceProvider).getPerformerPost(postId);
});

// ─── CREATE POST ──────────────────────────────────────────────────────────────
class CreatePostNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<String?> create({
    required String title,
    required String description,
    required String category,
    required int askingPrice,
    required DateTime deadline,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _svc.createPerformerPost({
        'title': title,
        'description': description,
        'category': category,
        'asking_price': askingPrice,
        'deadline': deadline.toIso8601String(),
      });
      state = const AsyncValue.data(null);
      return result['post_id'] as String?;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final createPostProvider =
    NotifierProvider<CreatePostNotifier, AsyncValue<void>>(CreatePostNotifier.new);

// ─── FUND POST ────────────────────────────────────────────────────────────────
class FundPostNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<bool> fund(String postId) async {
    state = const AsyncValue.loading();
    try {
      await _svc.invokeFunction('performer-post-fund', body: {'post_id': postId});
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final fundPostProvider =
    NotifierProvider<FundPostNotifier, AsyncValue<void>>(FundPostNotifier.new);
