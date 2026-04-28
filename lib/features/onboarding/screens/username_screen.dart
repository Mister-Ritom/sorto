// lib/features/onboarding/screens/username_screen.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/sorto_button.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

enum _AvailabilityState { idle, checking, available, taken }

class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  _AvailabilityState _avail = _AvailabilityState.idle;
  String? _error;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onType);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focus);
    });
  }

  void _onType() {
    final val = _ctrl.text.trim().toLowerCase();
    ref.read(onboardingProvider.notifier).setUsername(val);
    _error = Validators.username(val);
    if (_error != null || val.isEmpty) {
      setState(() {
        _avail = _AvailabilityState.idle;
        _suggestions = [];
      });
      _debounce?.cancel();
      return;
    }
    setState(() => _avail = _AvailabilityState.checking);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _check(val));
  }

  Future<void> _check(String username) async {
    final svc = ref.read(supabaseServiceProvider);
    try {
      final available = await svc.isUsernameAvailable(username);
      if (!mounted) return;
      setState(() {
        _avail = available
            ? _AvailabilityState.available
            : _AvailabilityState.taken;
        if (!available) {
          _suggestions = [
            '${username}99',
            '${username}_',
            'the_$username',
            '$username${DateTime.now().year}',
          ];
        } else {
          _suggestions = [];
        }
      });
    } catch (e, st) {
      dev.log('Error checking username availability',
          error: e, stackTrace: st, name: 'UsernameScreen');
      if (mounted) setState(() => _avail = _AvailabilityState.idle);
    }
  }

  bool get _canProceed =>
      _avail == _AvailabilityState.available && _error == null;

  void _proceed() {
    if (!_canProceed) return;
    HapticFeedback.mediumImpact();
    context.go(Routes.notificationOnboarding);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = _ctrl.text.trim();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'What do they\ncall you?',
                style: AppTypography.displayM(color: AppColors.darkTextPrimary),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                'This is your identity on Sorto. Make it good.',
                style: AppTypography.bodyM(color: AppColors.darkTextSecondary),
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),

              // ── Large display input ───────────────────────────────────────
              Stack(
                children: [
                  TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    style: AppTypography.usernameDisplay(
                      color: AppColors.darkTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_\.]')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'yourusername',
                      hintStyle: AppTypography.usernameDisplay(
                        color: AppColors.darkTextMuted,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _AvailabilityIcon(state: _avail)),
                  ),
                ],
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

              // Underline
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: _canProceed
                      ? AppColors.brandGradient
                      : LinearGradient(
                          colors: [
                            AppColors.darkCardBorder,
                            AppColors.darkCardBorder,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 12),
              if (_error != null && username.isNotEmpty)
                Text(
                  _error!,
                  style: AppTypography.bodyS(color: AppColors.error),
                ).animate().fadeIn(duration: 200.ms),

              // ── Creator card preview ──────────────────────────────────────
              const SizedBox(height: 32),
              AnimatedOpacity(
                opacity: username.isNotEmpty ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 300),
                child: _CreatorCardPreview(
                  username: username.isEmpty ? 'yourusername' : username,
                  isAvailable: _canProceed,
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

              // ── Suggestions ───────────────────────────────────────────────
              if (_suggestions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'How about one of these?',
                  style: AppTypography.bodyS(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _suggestions.map((s) {
                    return GestureDetector(
                      onTap: () {
                        _ctrl.text = s;
                        _ctrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: s.length),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacityNew(0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.primary.withOpacityNew(0.3),
                          ),
                        ),
                        child: Text(
                          s,
                          style: AppTypography.labelM(color: AppColors.primary),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 48),
              SortoButton(
                label: "That's me →",
                onPressed: _canProceed ? _proceed : null,
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityIcon extends StatelessWidget {
  const _AvailabilityIcon({required this.state});
  final _AvailabilityState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: switch (state) {
        _AvailabilityState.idle => const SizedBox.shrink(key: ValueKey('idle')),
        _AvailabilityState.checking => const SizedBox(
          key: ValueKey('checking'),
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        _AvailabilityState.available => const Icon(
          Icons.check_circle_rounded,
          key: ValueKey('ok'),
          color: AppColors.success,
          size: 24,
        ),
        _AvailabilityState.taken => const Icon(
          Icons.cancel_rounded,
          key: ValueKey('taken'),
          color: AppColors.error,
          size: 24,
        ),
      },
    );
  }
}

class _CreatorCardPreview extends StatelessWidget {
  const _CreatorCardPreview({
    required this.username,
    required this.isAvailable,
  });
  final String username;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? AppColors.primary : AppColors.darkCardBorder,
          width: isAvailable ? 1.5 : 1,
        ),
        boxShadow: isAvailable
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacityNew(0.2),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientDiagonal,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: AppTypography.headingL(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$username',
                  style: AppTypography.headingS(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                Text(
                  '0 followers · 0 dares',
                  style: AppTypography.bodyS(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'New',
              style: AppTypography.labelS(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
