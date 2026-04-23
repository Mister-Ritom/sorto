// lib/features/auth/screens/sign_up_screen.dart
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
import '../auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    await ref.read(authNotifierProvider.notifier).signUp(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _usernameCtrl.text.trim().toLowerCase(),
        );
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
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Sorto.',
                style: AppTypography.displayS(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 6),
              Text(
                'Dare. Perform. Earn.',
                style: AppTypography.bodyM(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 36),

              // Username
              TextFormField(
                controller: _usernameCtrl,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_\.]')),
                ],
                validator: Validators.username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 16),

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
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
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
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 16),

              // Confirm password
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                validator: (v) =>
                    Validators.confirmPassword(v, _passwordCtrl.text),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),

              SortoButton(
                label: 'Create Account',
                isLoading: isLoading,
                onPressed: isLoading ? null : _signUp,
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'By signing up, you agree to our Terms of Service.',
                  style:
                      AppTypography.bodyS(color: AppColors.darkTextMuted),
                  textAlign: TextAlign.center,
                ).animate(delay: 700.ms).fadeIn(duration: 300.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
