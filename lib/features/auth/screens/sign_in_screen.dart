// lib/features/auth/screens/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../../../shared/widgets/sorto_logo.dart';
import '../auth_provider.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    await ref
        .read(authNotifierProvider.notifier)
        .signIn(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (state is AsyncData) {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // BG
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF0E0118), AppColors.darkBackground],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [AppColors.lightBackground, AppColors.lightSurface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
          ),

          // Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacityNew(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    Row(
                      children: [
                        const SortoLogo(size: 40),
                        const SizedBox(width: 10),
                        Text('Sorto',
                            style: AppTypography.headingL(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary)),
                      ],
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 48),

                    Text(
                      'Welcome back.',
                      style: AppTypography.displayS(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to your account.',
                      style: AppTypography.bodyM(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 40),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: Validators.email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      validator: Validators.password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(Routes.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ).animate(delay: 450.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 24),

                    SortoButton(
                      label: 'Sign in',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _signIn,
                    ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or continue with',
                            style: AppTypography.bodyS(
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ).animate(delay: 600.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 16),

                    // Google OAuth
                    SortoButton(
                      label: 'Continue with Google',
                      variant: SortoButtonVariant.outline,
                      icon: Icons.g_mobiledata_rounded,
                      onPressed: () => ref
                          .read(authNotifierProvider.notifier)
                          .signInWithGoogle(),
                    ).animate(delay: 650.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.bodyM(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.push(Routes.signUp),
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.brandGradient.createShader(bounds),
                            child: Text(
                              'Sign up',
                              style: AppTypography.labelL(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ).animate(delay: 700.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
