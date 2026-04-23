// lib/shared/widgets/skeleton_loader.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor:
          isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8E0F5),
      highlightColor:
          isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F0FF),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DareCardSkeleton extends StatelessWidget {
  const DareCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCardBorder
              : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(width: 40, height: 40, borderRadius: 100),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 100, height: 12),
                  SizedBox(height: 6),
                  SkeletonBox(width: 70, height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonBox(width: double.infinity, height: 22),
          const SizedBox(height: 8),
          const SkeletonBox(width: 240, height: 16),
          const SizedBox(height: 16),
          Row(
            children: const [
              SkeletonBox(width: 70, height: 28, borderRadius: 100),
              SizedBox(width: 8),
              SkeletonBox(width: 55, height: 28, borderRadius: 100),
              Spacer(),
              SkeletonBox(width: 90, height: 36, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SkeletonBox(width: 52, height: 52, borderRadius: 100),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 140, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 100, height: 11),
              ],
            ),
          ),
          const SkeletonBox(width: 80, height: 32, borderRadius: 100),
        ],
      ),
    );
  }
}

class TransactionSkeleton extends StatelessWidget {
  const TransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const SkeletonBox(width: 40, height: 40, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 160, height: 13),
                SizedBox(height: 5),
                SkeletonBox(width: 90, height: 11),
              ],
            ),
          ),
          const SkeletonBox(width: 65, height: 18),
        ],
      ),
    );
  }
}

class BentoGridSkeleton extends StatelessWidget {
  const BentoGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                  child: SkeletonBox(
                      width: double.infinity, height: 200)),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    SkeletonBox(width: double.infinity, height: 95),
                    SizedBox(height: 8),
                    SkeletonBox(width: double.infinity, height: 95),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(
                child: Column(
                  children: [
                    SkeletonBox(width: double.infinity, height: 95),
                    SizedBox(height: 8),
                    SkeletonBox(width: double.infinity, height: 95),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                  child: SkeletonBox(
                      width: double.infinity, height: 200)),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    required this.itemBuilder,
    this.count = 5,
  });

  final Widget Function(int index) itemBuilder;
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (ctx, i) => itemBuilder(i),
    );
  }
}
