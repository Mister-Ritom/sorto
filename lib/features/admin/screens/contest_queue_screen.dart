// lib/features/admin/screens/contest_queue_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/dares/dares_provider.dart';
import '../../../features/profile/widgets/profile_widgets.dart';

class ContestQueueScreen extends ConsumerWidget {
  const ContestQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final underReviewAsync = ref.watch(underReviewDaresProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Contest Queue', style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              // ignore: unused_result — intentional fire-and-forget refresh
              ref.refresh(underReviewDaresProvider);
            },
          ),
        ],
      ),
      body: underReviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (dares) {
          if (dares.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚖️', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text('Empty Queue', style: AppTypography.headingM()),
                  const SizedBox(height: 12),
                  Text(
                    'No dares are currently pending admin review.',
                    style: AppTypography.bodyM(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dares.length,
            itemBuilder: (ctx, i) => DareMiniCard(dare: dares[i]),
          );
        },
      ),
    );
  }
}
