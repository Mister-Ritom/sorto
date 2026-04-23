// lib/features/onboarding/screens/role_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/animated_coin.dart';

class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key});

  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen>
    with TickerProviderStateMixin {
  UserRole? _selected;
  bool _animating = false;
  final _burstController = AnimatedCoinBurstController();

  Future<void> _selectRole(UserRole role) async {
    if (_animating) return;
    setState(() {
      _selected = role;
      _animating = true;
    });
    HapticFeedback.mediumImpact();
    _burstController.fire();
    await Future.delayed(const Duration(milliseconds: 400));
    ref.read(onboardingProvider.notifier).setRole(role);
    if (mounted) context.go(Routes.interestOnboarding);
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: AnimatedCoinBurst(
          controller: _burstController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'First things first —',
                  style: AppTypography.bodyL(
                    color: AppColors.darkTextSecondary,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                      "What's your\nvibe?",
                      style: AppTypography.displayM(
                        color: AppColors.darkTextPrimary,
                      ),
                    )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 48),

                // Role cards
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child:
                            _RoleCard(
                                  emoji: '💰',
                                  title: "I'm a\nPoster",
                                  subtitle:
                                      'I fund dares and watch people actually do them',
                                  color: AppColors.accent,
                                  isSelected: _selected == UserRole.poster,
                                  onTap: () => _selectRole(UserRole.poster),
                                )
                                .animate(delay: 300.ms)
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.3, end: 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            _RoleCard(
                                  emoji: '🎬',
                                  title: "I'm a\nPerformer",
                                  subtitle:
                                      'I complete dares and get paid real money',
                                  color: AppColors.primary,
                                  isSelected: _selected == UserRole.performer,
                                  onTap: () => _selectRole(UserRole.performer),
                                )
                                .animate(delay: 400.ms)
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: 0.3, end: 0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'You can switch anytime. Or be both.',
                    style: AppTypography.bodyS(color: AppColors.darkTextMuted),
                  ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _glow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_RoleCard old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      if (widget.isSelected) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) => Transform.scale(
        scale: _scale.value,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isSelected
                    ? widget.color
                    : AppColors.darkCardBorder,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.35 * _glow.value),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  widget.title,
                  style: AppTypography.displayS(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: AppTypography.bodyS(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
