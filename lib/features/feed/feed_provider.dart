// lib/features/feed/feed_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/dare.dart';
import '../../shared/models/performer_post.dart';

// ─── DARE FEED ────────────────────────────────────────────────────────────────
class DareFeedState {
  final List<Dare> dares;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final String? category;
  final String? mode;
  final int offset;

  const DareFeedState({
    this.dares = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.category,
    this.mode,
    this.offset = 0,
  });

  DareFeedState copyWith({
    List<Dare>? dares,
    bool? isLoading,
    bool? hasMore,
    String? error,
    String? category,
    String? mode,
    int? offset,
  }) =>
      DareFeedState(
        dares: dares ?? this.dares,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        error: error,
        category: category ?? this.category,
        mode: mode ?? this.mode,
        offset: offset ?? this.offset,
      );
}

class DareFeedNotifier extends Notifier<DareFeedState> {
  @override
  DareFeedState build() {
    Future.microtask(() => load());
    return const DareFeedState();
  }

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<void> load({bool refresh = false}) async {
    if (!refresh && (state.isLoading || !state.hasMore)) return;

    final offset = refresh ? 0 : state.offset;
    state = state.copyWith(isLoading: true, error: null, offset: offset,
        dares: refresh ? [] : state.dares, hasMore: true);

    try {
      final dares = await _svc.getDares(
        limit: AppConstants.defaultPageSize,
        offset: offset,
        category: state.category,
        mode: state.mode,
        status: 'open',
      );
      final hasMore = dares.length == AppConstants.defaultPageSize;
      final current = refresh ? <Dare>[] : state.dares;
      state = state.copyWith(
        dares: [...current, ...dares],
        isLoading: false,
        hasMore: hasMore,
        offset: offset + dares.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void loadMore() => load();
  void refresh() => load(refresh: true);

  void filterCategory(String? category) {
    state = DareFeedState(category: category, mode: state.mode, isLoading: true);
    load(refresh: true);
  }

  void filterMode(String? mode) {
    state = DareFeedState(category: state.category, mode: mode, isLoading: true);
    load(refresh: true);
  }
}

final dareFeedProvider = NotifierProvider<DareFeedNotifier, DareFeedState>(
  DareFeedNotifier.new,
);

// ─── async value wrapper for UI ───────────────────────────────────────────────
final dareFeedAsyncProvider = Provider<AsyncValue<List<Dare>>>((ref) {
  final s = ref.watch(dareFeedProvider);
  if (s.isLoading && s.dares.isEmpty) return const AsyncValue.loading();
  if (s.error != null && s.dares.isEmpty) {
    return AsyncValue.error(s.error!, StackTrace.empty);
  }
  return AsyncValue.data(s.dares);
});

// ─── TREND CREATORS ───────────────────────────────────────────────────────────
final trendCreatorsProvider = FutureProvider<List<PerformerPost>>((ref) {
  return ref.read(supabaseServiceProvider).getPerformerPosts(
    status: 'open',
    limit: 10,
  );
});

// ─── SEARCH ───────────────────────────────────────────────────────────────────
class SearchNotifier extends Notifier<AsyncValue<List<Dare>>> {
  @override
  AsyncValue<List<Dare>> build() => const AsyncValue.data([]);

  SupabaseService get _svc => ref.read(supabaseServiceProvider);

  Future<void> search(String query, {String? category, String? mode}) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      var q = _svc.client
          .from('dares')
          .select('*, profiles!poster_id(username, avatar_url, display_name)')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('status', 'open');
      if (category != null) q = q.eq('category', category);
      if (mode != null) q = q.eq('dare_mode', mode);
      final data = await q.limit(30);
      state = AsyncValue.data(
          data.map<Dare>((e) => Dare.fromJson(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() => state = const AsyncValue.data([]);
}

final searchProvider =
    NotifierProvider<SearchNotifier, AsyncValue<List<Dare>>>(SearchNotifier.new);
