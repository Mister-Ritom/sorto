// lib/features/onboarding/screens/launch_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/animated_coin.dart';
import '../../../shared/widgets/sorto_logo.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen> {
  int _typewriterIndex = 0;
  final List<String> _phrases = [
    'Your dares.',
    'Your money.',
    'Your rules.',
  ];
  String _displayed = '';
  bool _showButton = false;
  Timer? _charTimer;
  Timer? _phaseTimer;
  final _burstController = AnimatedCoinBurstController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), _startTypewriter);
  }

  void _startTypewriter() {
    if (!mounted) return;
    _typePhrase(0);
  }

  void _typePhrase(int phraseIndex) {
    if (!mounted || phraseIndex >= _phrases.length) {
      // All phrases done — show button
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showButton = true);
      });
      return;
    }

    final phrase = _phrases[phraseIndex];
    int charIndex = 0;

    // Clear and start pause
    setState(() => _displayed = '');
    Future.delayed(Duration(milliseconds: phraseIndex == 0 ? 0 : 400), () {
      if (!mounted) return;
      _charTimer = Timer.periodic(
        const Duration(milliseconds: 60),
        (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          if (charIndex < phrase.length) {
            setState(() => _displayed = '$_displayed${phrase[charIndex]}');
            charIndex++;
          } else {
            timer.cancel();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              // Show next phrase below
              _phaseTimer = Timer(const Duration(milliseconds: 200), () {
                _typePhrase(phraseIndex + 1);
              });
            });
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _charTimer?.cancel();
    _phaseTimer?.cancel();
    _burstController.dispose();
    super.dispose();
  }

  void _launch() async {
    HapticFeedback.mediumImpact();
    _burstController.fire();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      // Write locally — instant, no DB round-trip
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefOnboardingDone, true);
      if (mounted) context.go(Routes.home);
    } else {
      context.go(Routes.signUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: AnimatedCoinBurst(
        controller: _burstController,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo
                const SortoLogo(size: 80, style: SortoLogoStyle.dark)
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 48),

                // Phrases typewriter
                _TypewriterDisplay(phrases: _phrases),

                const Spacer(flex: 2),

                // Launch button
                AnimatedOpacity(
                  opacity: _showButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: AnimatedSlide(
                    offset: _showButton ? Offset.zero : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: SortoButton(
                      label: 'Enter Sorto →',
                      onPressed: _launch,
                      height: 64,
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                          begin: 1.0,
                          end: 1.02,
                          duration: 1500.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypewriterDisplay extends StatefulWidget {
  const _TypewriterDisplay({required this.phrases});
  final List<String> phrases;

  @override
  State<_TypewriterDisplay> createState() => _TypewriterDisplayState();
}

class _TypewriterDisplayState extends State<_TypewriterDisplay> {
  final List<String> _completed = [];
  String _current = '';
  int _phraseIndex = 0;
  Timer? _charTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), _startNext);
  }

  void _startNext() {
    if (!mounted || _phraseIndex >= widget.phrases.length) return;
    final phrase = widget.phrases[_phraseIndex];
    String current = '';
    int charIndex = 0;

    _charTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) { t.cancel(); return; }
      if (charIndex < phrase.length) {
        current += phrase[charIndex];
        charIndex++;
        setState(() => _current = current);
      } else {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() {
            _completed.add(phrase);
            _current = '';
            _phraseIndex++;
          });
          Future.delayed(const Duration(milliseconds: 100), _startNext);
        });
      }
    });
  }

  @override
  void dispose() {
    _charTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Completed phrases (static, with gradient)
        ..._completed.map((p) => ShaderMask(
              shaderCallback: (b) =>
                  AppColors.brandGradient.createShader(b),
              child: Text(
                p,
                style: AppTypography.typewriter(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(duration: 300.ms)),

        // Current phrase being typed
        if (_current.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _current,
                style: AppTypography.typewriter(
                    color: AppColors.darkTextPrimary),
                textAlign: TextAlign.center,
              ),
              // Cursor blink
              _BlinkingCursor(),
            ],
          ),
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 3,
        height: 36,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
