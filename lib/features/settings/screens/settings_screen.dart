// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../../../core/services/pwa_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sorto/core/extensions/color_extensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.headingM()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ─── ACCOUNT SECTION ───────────────────────────────────────────────
          _SectionHeader(
            title: 'Account',
          ).animate().fadeIn(delay: 50.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          profileAsync.when(
            data: (profile) => _ProfileTile(
              name: profile?.displayName ?? 'User',
              username: '@${profile?.username ?? 'username'}',
              avatarUrl: profile?.avatarUrl,
              onTap: () {
                // TODO: Edit Profile
              },
            ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
            loading: () => const _LoadingTile(),
            error: (_, _) => const _ErrorTile(),
          ),
          const SizedBox(height: 32),

          // ─── PREFERENCES SECTION ───────────────────────────────────────────
          _SectionHeader(
            title: 'Preferences',
          ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.palette_rounded,
            title: 'Theme Mode',
            subtitle: _getThemeName(themeMode),
            onTap: () => _showThemePicker(context, ref),
          ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1, end: 0),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Push, Email, and SMS',
            onTap: () {
              // TODO: Notification Settings
            },
          ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.1, end: 0),
          const SizedBox(height: 32),

          // ─── SUPPORT SECTION ───────────────────────────────────────────────
          _SectionHeader(
            title: 'Support',
          ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            onTap: () {},
          ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.1, end: 0),
          _SettingsTile(
            icon: Icons.description_rounded,
            title: 'Terms of Service',
            onTap: () {},
          ).animate(delay: 450.ms).fadeIn().slideX(begin: 0.1, end: 0),
          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            onTap: () {},
          ).animate(delay: 500.ms).fadeIn().slideX(begin: 0.1, end: 0),
          const SizedBox(height: 32),

          // ─── APP SECTION (PWA) ─────────────────────────────────────────────
          if (kIsWeb) ...[
            StreamBuilder<bool>(
              stream: ref.watch(pwaServiceProvider).installableStream,
              initialData: ref.watch(pwaServiceProvider).isInstallable,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'App')
                          .animate()
                          .fadeIn(delay: 550.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 12),
                      _SettingsTile(
                            icon: Icons.install_mobile_rounded,
                            title: 'Install App',
                            subtitle: 'Add Sorto to your home screen',
                            onTap: () {
                              ref
                                  .read(pwaServiceProvider)
                                  .showInstallBanner(context, force: true);
                            },
                          )
                          .animate(delay: 600.ms)
                          .fadeIn()
                          .slideX(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],

          // ─── DANGER ZONE ───────────────────────────────────────────────────
          SortoButton(
            label: 'Logout',
            variant: SortoButtonVariant.danger,
            onPressed: () => _showLogoutDialog(context, ref),
            icon: Icons.logout_rounded,
          ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context),
              child: Text(
                'Delete Account',
                style: AppTypography.bodyM(color: AppColors.error),
              ),
            ),
          ).animate(delay: 700.ms).fadeIn(),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Sorto v1.0.0',
              style: AppTypography.bodyS(
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final currentMode = ref.watch(themeModeProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Appearance', style: AppTypography.headingM()),
                  const SizedBox(height: 16),
                  _ThemeOption(
                    title: 'System Default',
                    isSelected: currentMode == ThemeMode.system,
                    onTap: () {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.system);
                      Navigator.pop(ctx);
                    },
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                  _ThemeOption(
                    title: 'Light Mode',
                    isSelected: currentMode == ThemeMode.light,
                    onTap: () {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.light);
                      Navigator.pop(ctx);
                    },
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
                  _ThemeOption(
                    title: 'Dark Mode',
                    isSelected: currentMode == ThemeMode.dark,
                    onTap: () {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.dark);
                      Navigator.pop(ctx);
                    },
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to sign out of Sorto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(Routes.signIn);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'This action is permanent. All your data, wallet balance, and history will be lost forever.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep My Account'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion logic
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.displayS().copyWith(
        fontSize: 14,
        letterSpacing: 1.2,
        color: AppColors.primary,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.onTap,
  });

  final String name;
  final String username;
  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacityNew(0.1),
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? const Icon(Icons.person_rounded, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.headingM()),
                Text(
                  username,
                  style: AppTypography.bodyM(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.edit_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withOpacityNew(0.05)
                  : Colors.black.withOpacityNew(0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: AppTypography.headingS()),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodyS(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: AppTypography.bodyL()),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : const Icon(Icons.circle_outlined),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacityNew(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Failed to load profile info'),
      leading: Icon(Icons.error_outline_rounded, color: AppColors.error),
    );
  }
}
