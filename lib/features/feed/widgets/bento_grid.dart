// lib/features/feed/widgets/bento_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../shared/models/performer_post.dart';
import 'creator_bento_card.dart';

class BentoGrid extends StatelessWidget {
  const BentoGrid({
    super.key,
    required this.posts,
    this.padding = const EdgeInsets.all(16),
  });

  final List<PerformerPost> posts;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (ctx, i) {
          // Alternate heights for bento feel
          final isLong = i % 3 == 0;
          return SizedBox(
            height: isLong ? 220 : 160,
            child: CreatorBentoCard(post: posts[i]),
          );
        },
      ),
    );
  }
}
