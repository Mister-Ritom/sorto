// lib/features/onboarding/screens/interest_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/sorto_button.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class InterestScreen extends ConsumerStatefulWidget {
  const InterestScreen({super.key});

  @override
  ConsumerState<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends ConsumerState<InterestScreen> {
  final Map<String, bool> _floatingEmojis = {};

  void _toggle(String category) {
    HapticFeedback.lightImpact();
    ref.read(onboardingProvider.notifier).toggleCategory(category);
    // Show floating emoji
    setState(() {
      _floatingEmojis[category] = true;
    });
    Future.delayed(const Duration(milliseconds: 800),
        () => setState(() => _floatingEmojis.remove(category)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final isPerformer = state.role == UserRole.performer;
    final selected = state.selectedCategories;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                isPerformer
                    ? 'What would you\nactually do?'
                    : 'What kind of dares\nwould you fund?',
                style: AppTypography.displayS(
                    color: AppColors.darkTextPrimary),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 32),

              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.dareCategories.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final emoji = AppConstants.categoryEmoji[cat] ?? '🎯';
                    final isSelected = selected.contains(cat);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _CategoryChip(
                          emoji: emoji,
                          label: cat,
                          isSelected: isSelected,
                          onTap: () => _toggle(cat),
                        ).animate(delay: (i * 60).ms).fadeIn(duration: 300.ms).slideY(begin: 0.4, end: 0),

                        // Floating emoji micro-reward
                        if (_floatingEmojis.containsKey(cat))
                          Positioned(
                            top: -20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 22),
                              )
                                  .animate()
                                  .moveY(begin: 0, end: -30, duration: 700.ms)
                                  .fadeOut(delay: 400.ms, duration: 300.ms),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),
              SortoButton(
                label: isPerformer
                    ? "I'd crush these dares →"
                    : 'These are my kind of dares →',
                onPressed: selected.isEmpty
                    ? null
                    : () => context.go(Routes.socialProofOnboarding),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_CategoryChip old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      if (widget.isSelected) {
        _ctrl.forward().then((_) => _ctrl.reverse());
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
      animation: _scale,
      builder: (ctx, _) => Transform.scale(
        scale: _scale.value,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary.withOpacityNew(0.2)
                  : AppColors.darkCard,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary
                    : AppColors.darkCardBorder,
                width: widget.isSelected ? 1.5 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacityNew(0.25),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.emoji,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: AppTypography.labelL(
                    color: widget.isSelected
                        ? AppColors.primary
                        : AppColors.darkTextPrimary,
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
