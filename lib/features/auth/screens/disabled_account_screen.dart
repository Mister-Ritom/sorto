// lib/features/auth/screens/disabled_account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../auth_provider.dart';
import '../../../core/router/app_router.dart';

class DisabledAccountScreen extends ConsumerWidget {
  const DisabledAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null || !profile.isDisabled) {
              // If not disabled, go home (safety check)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(Routes.home);
              });
              return const SizedBox.shrink();
            }

            final disabledDate = profile.disabledAt ?? DateTime.now();
            final deletionDate = disabledDate.add(const Duration(days: 90));
            final daysRemaining = deletionDate.difference(DateTime.now()).inDays;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_accounts_rounded,
                    size: 80,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Account Disabled',
                    style: AppTypography.headingL(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your account was disabled on ${DateFormat('MMM dd, yyyy').format(disabledDate)}. '
                    'It is scheduled for permanent deletion in $daysRemaining days.',
                    style: AppTypography.bodyL(color: AppColors.lightTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SortoButton(
                    label: 'Cancel Deletion',
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).enableAccount();
                      if (context.mounted) context.go(Routes.home);
                    },
                  ),
                  const SizedBox(height: 16),
                  SortoButton(
                    label: 'Logout',
                    variant: SortoButtonVariant.secondary,
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) context.go(Routes.signIn);
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
