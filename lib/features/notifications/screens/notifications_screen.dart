// lib/features/notifications/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/notification_model.dart';
import '../notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsStreamProvider);
    final notifier = ref.read(notificationsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => notifier.markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 56))
                      .animate().scale(curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text('No notifications yet',
                      style: AppTypography.headingS())
                      .animate(delay: 200.ms).fadeIn(),
                  const SizedBox(height: 6),
                  Text('Activity on your dares will appear here.',
                      style: AppTypography.bodyM())
                      .animate(delay: 300.ms).fadeIn(),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: notifs.length,
            itemBuilder: (ctx, i) => _NotificationRow(
              notif: notifs[i],
              onTap: () {
                HapticFeedback.lightImpact();
                notifier.markRead(notifs[i].id);
                // Navigate based on type
                final n = notifs[i];
                if (n.dareId != null) {
                  context.push(Routes.dareDetailPath(n.dareId!));
                }
              },
              animationDelay: Duration(milliseconds: i * 40),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.notif,
    required this.onTap,
    required this.animationDelay,
  });
  final SortoNotification notif;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notif.isRead;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withOpacity(0.06)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withOpacity(0.2)
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(notif.typeIcon,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.body,
                    style: AppTypography.bodyM(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.shortDate(notif.createdAt),
                    style: AppTypography.bodyS(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
