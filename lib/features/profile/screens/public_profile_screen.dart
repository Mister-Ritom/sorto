// lib/features/profile/screens/public_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../profile_provider.dart';
import '../widgets/profile_widgets.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({super.key, required this.username});
  final String username;

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(publicProfileProvider(widget.username));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username, style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: profileAsync.when(
        loading: () => const ProfileCardSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text('User not found', style: AppTypography.headingS()));
          }

          return NestedScrollView(
            headerSliverBuilder: (ctx, inner) => [
              SliverToBoxAdapter(
                child: ProfileHeader(profile: profile, isOwn: false),
              ),
              SliverPersistentHeader(
                delegate: _TabDelegate(_tabController),
                pinned: true,
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _UserDares(userId: profile.id),
                _UserPosts(userId: profile.id),
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
          Tab(text: 'Dares Posted'),
          Tab(text: 'Performer Posts'),
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

class _UserDares extends ConsumerWidget {
  const _UserDares({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daresAsync = ref.watch(userDaresProvider(userId));
    return daresAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (dares) {
        if (dares.isEmpty) {
          return const EmptyProfileTab(
            emoji: '🎯',
            message: 'No dares posted',
            hint: 'This user hasn\'t posted any dares yet.',
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

class _UserPosts extends ConsumerWidget {
  const _UserPosts({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPerformerPostsProvider(userId));
    return postsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (posts) {
        if (posts.isEmpty) {
          return const EmptyProfileTab(
            emoji: '🎬',
            message: 'No performer posts',
            hint: 'This user hasn\'t posted any performer ads.',
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
