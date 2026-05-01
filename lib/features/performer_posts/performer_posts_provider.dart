// lib/features/performer_posts/performer_posts_provider.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/models/performer_post.dart';
import '../../core/constants/app_constants.dart';

// ─── ALL POSTS FEED ───────────────────────────────────────────────────────────
class PerformerPostsState {
  final List<PerformerPost> posts;
  final bool isLoading;
  final bool hasMore;
  final int offset;
  final String? error;

  const PerformerPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.offset = 0,
    this.error,
  });

  PerformerPostsState copyWith({
    List<PerformerPost>? posts,
    bool? isLoading,
    bool? hasMore,
    int? offset,
    String? error,
  }) =>
      PerformerPostsState(
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        offset: offset ?? this.offset,
        error: error,
      );
}

class PerformerPostsNotifier extends Notifier<PerformerPostsState> {
  @override
  PerformerPostsState build() {
    Future.microtask(() => load());
    return const PerformerPostsState();
  }

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<void> load({bool refresh = false}) async {
    if (!refresh && (state.isLoading || !state.hasMore)) return;

    final offset = refresh ? 0 : state.offset;
    state = state.copyWith(
      isLoading: true,
      error: null,
      offset: offset,
      posts: refresh ? [] : state.posts,
      hasMore: true,
    );

    try {
      final posts = await _svc.getPerformerPosts(
        limit: AppConstants.defaultPageSize,
        offset: offset,
        status: 'open',
      );
      final hasMore = posts.length == AppConstants.defaultPageSize;
      final current = refresh ? <PerformerPost>[] : state.posts;
      state = state.copyWith(
        posts: [...current, ...posts],
        isLoading: false,
        hasMore: hasMore,
        offset: offset + posts.length,
      );
    } catch (e, st) {
      dev.log('Error loading performer posts',
          error: e, stackTrace: st, name: 'PerformerPostsNotifier');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load posts.',
      );
    }
  }

  void loadMore() => load();
  void refresh() => load(refresh: true);
}

final performerPostsFeedProvider =
    NotifierProvider<PerformerPostsNotifier, PerformerPostsState>(
  PerformerPostsNotifier.new,
);

final performerPostsFeedAsyncProvider = Provider<AsyncValue<List<PerformerPost>>>((ref) {
  final s = ref.watch(performerPostsFeedProvider);
  if (s.isLoading && s.posts.isEmpty) return const AsyncValue.loading();
  if (s.error != null && s.posts.isEmpty) {
    return AsyncValue.error(s.error!, StackTrace.empty);
  }
  return AsyncValue.data(s.posts);
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
      dev.log('Error creating performer post', error: e, stackTrace: st, name: 'CreatePostNotifier');
      state = AsyncValue.error('Failed to create post. Please try again.', st);
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
      dev.log('Error funding post', error: e, stackTrace: st, name: 'FundPostNotifier');
      state = AsyncValue.error('Funding failed. Please try again.', st);
      return false;
    }
  }
}

final fundPostProvider =
    NotifierProvider<FundPostNotifier, AsyncValue<void>>(FundPostNotifier.new);
