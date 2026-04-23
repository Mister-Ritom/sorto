// lib/features/onboarding/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(AppConstants.splashDuration, _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;

    // Not logged in → start of onboarding
    if (user == null) {
      context.go(Routes.hookOnboarding);
      return;
    }

    // Logged in → check local flag (instant, no network)
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(AppConstants.prefOnboardingDone) ?? false;

    if (!mounted) return;

    context.go(done ? Routes.home : Routes.usernameOnboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo mark
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradientDiagonal,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text('⚡', style: TextStyle(fontSize: 52)),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            Text(
              'Sorto',
              style: AppTypography.displayL(color: AppColors.darkTextPrimary),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 12),

            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.brandGradient.createShader(bounds),
              child: Text(
                AppConstants.tagline,
                style: AppTypography.bodyL(color: Colors.white),
              ),
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 500.ms)
                .then(delay: 200.ms)
                .shimmer(duration: 1200.ms, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
