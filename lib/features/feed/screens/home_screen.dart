// lib/features/feed/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/feed/feed_provider.dart';
import '../../../features/notifications/notifications_provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/coin_chip.dart';
import '../../../shared/widgets/sorto_fab.dart';
import '../widgets/dare_card.dart';
import '../widgets/bento_grid.dart';
import 'package:sorto/core/services/pwa_service.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollCtrl = ScrollController();
  String? _categoryFilter;
  bool _fabCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollCtrl.addListener(_onScroll);

    // Show PWA install banner after login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(pwaServiceProvider)
          .showInstallBanner(
            context,
            bannerContext: PwaBannerContext.postLogin,
          );
    });
  }

  void _onScroll() {
    // Load more when approaching the end of the list
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(dareFeedProvider.notifier).loadMore();
    }
    // Collapse FAB when scrolling down, expand when scrolling up
    final scrollingDown =
        _scrollCtrl.position.userScrollDirection.name == 'reverse';
    if (scrollingDown != _fabCollapsed) {
      setState(() => _fabCollapsed = scrollingDown);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (ctx, inner) => [
          // ── Top Nav ─────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: bg,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: Consumer(
                builder: (ctx, ref, _) {
                  final profile = ref.watch(currentProfileProvider).value;
                  return CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withOpacityNew(0.1),
                    backgroundImage: profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: AppColors.primary,
                          )
                        : null,
                  );
                },
              ),
              onPressed: () => context.push(Routes.profileSelf),
            ),
            title: ShaderMask(
              shaderCallback: (b) => AppColors.brandGradient.createShader(b),
              child: Text(
                'Sorto',
                style: AppTypography.displayS(color: Colors.white),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.push(Routes.search),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () => context.push(Routes.notifications),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push(Routes.wallet),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CoinChip(
                    onTap: () => context.push(Routes.wallet),
                    compact: true,
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Dares'),
                Tab(text: 'Trend Creators'),
              ],
            ),
          ),

          // ── Category filter chips ────────────────────────────────────────
          SliverToBoxAdapter(
            child: _CategoryFilterBar(
              selected: _categoryFilter,
              onSelect: (cat) {
                setState(() => _categoryFilter = cat);
                ref.read(dareFeedProvider.notifier).filterCategory(cat);
              },
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── DARES TAB ────────────────────────────────────────────────
            _DaresFeed(categoryFilter: _categoryFilter),
            // ── TREND CREATORS TAB ───────────────────────────────────────
            _TrendCreatorsTab(),
          ],
        ),
      ),
      floatingActionButton: SortoFAB(
        collapsed: _fabCollapsed,
        onPressed: () => context.push(Routes.createDare),
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.selected, required this.onSelect});
  final String? selected;
  final void Function(String?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          _Chip(
            label: 'All',
            emoji: '🔥',
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          ...AppConstants.dareCategories.map(
            (cat) => _Chip(
              label: cat,
              emoji: AppConstants.categoryEmoji[cat] ?? '🎯',
              selected: selected == cat,
              onTap: () => onSelect(selected == cat ? null : cat),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacityNew(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.labelM(
                color: selected ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaresFeed extends ConsumerWidget {
  const _DaresFeed({this.categoryFilter});
  final String? categoryFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daresAsync = ref.watch(dareFeedAsyncProvider);
    final feedState = ref.watch(dareFeedProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.read(dareFeedProvider.notifier).refresh(),
      child: daresAsync.when(
        loading: () => ListView.builder(
          itemCount: 5,
          itemBuilder: (_, i) => const DareCardSkeleton(),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Something went wrong', style: AppTypography.headingS()),
              TextButton(
                onPressed: () => ref.read(dareFeedProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (dares) {
          if (dares.isEmpty) {
            return _EmptyFeed();
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: dares.length + (feedState.hasMore ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == dares.length) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return DareCard(
                dare: dares[i],
                animationDelay: Duration(milliseconds: i * 50),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎯',
            style: TextStyle(fontSize: 64),
          ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),
          const SizedBox(height: 16),
          Text(
            'No dares yet.',
            style: AppTypography.headingM(),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Be the first to post one.',
            style: AppTypography.bodyM(),
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _TrendCreatorsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(trendCreatorsProvider);

    return postsAsync.when(
      loading: () => const BentoGridSkeleton(),
      error: (_, _) => const Center(child: Text('Failed to load creators')),
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎬', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('No creator posts yet.', style: AppTypography.headingM()),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: BentoGrid(posts: posts),
        );
      },
    );
  }
}
