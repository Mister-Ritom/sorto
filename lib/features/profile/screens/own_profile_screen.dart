// lib/features/profile/screens/own_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../profile_provider.dart';
import '../widgets/profile_widgets.dart';

class OwnProfileScreen extends ConsumerStatefulWidget {
  const OwnProfileScreen({super.key});

  @override
  ConsumerState<OwnProfileScreen> createState() => _OwnProfileScreenState();
}

class _OwnProfileScreenState extends ConsumerState<OwnProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(ownProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.headingM()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push(Routes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const ProfileCardSkeleton(),
        error: (e, _) => Center(child: Text('Failed to load profile: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text('Profile not found', style: AppTypography.headingS()));
          }
          return NestedScrollView(
            headerSliverBuilder: (ctx, inner) => [
              SliverToBoxAdapter(
                child: ProfileHeader(
                  profile: profile,
                  isOwn: true,
                  onEditTap: () {
                    // TODO: Edit profile sheet
                  },
                ),
              ),
              SliverPersistentHeader(
                delegate: _TabDelegate(_tabController),
                pinned: true,
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _PostedDares(userId: profile.id),
                _CompletedDares(userId: profile.id),
                _PerformerPosts(userId: profile.id),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  const _TabDelegate(this.tabController);
  final TabController tabController;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: 'Posted'),
          Tab(text: 'Completed'),
          Tab(text: 'My Posts'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 46;

  @override
  double get minExtent => 46;

  @override
  bool shouldRebuild(_TabDelegate other) => false;
}

class _PostedDares extends ConsumerWidget {
  const _PostedDares({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daresAsync = ref.watch(myPostedDaresProvider);
    return daresAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (dares) {
        if (dares.isEmpty) {
          return const EmptyProfileTab(
            emoji: '🎯',
            message: 'No dares posted yet',
            hint: 'Tap + to post your first dare',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dares.length,
          itemBuilder: (ctx, i) => DareMiniCard(dare: dares[i]),
        );
      },
    );
  }
}

class _CompletedDares extends ConsumerWidget {
  const _CompletedDares({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daresAsync = ref.watch(myCompletedDaresProvider);
    return daresAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (dares) {
        if (dares.isEmpty) {
          return const EmptyProfileTab(
            emoji: '🏆',
            message: 'No dares completed yet',
            hint: 'Browse the feed and claim a dare',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dares.length,
          itemBuilder: (ctx, i) => DareMiniCard(
              dare: dares[i], showEarnings: true),
        );
      },
    );
  }
}

class _PerformerPosts extends ConsumerWidget {
  const _PerformerPosts({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(myPerformerPostsProvider);
    return postsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (posts) {
        if (posts.isEmpty) {
          return const EmptyProfileTab(
            emoji: '🎬',
            message: 'No performer posts yet',
            hint: 'Post what dares you\'d do for money',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (ctx, i) => PostMiniCard(post: posts[i]),
        );
      },
    );
  }
}
