// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(_emailCtrl.text.trim());
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _SuccessState() : _FormState(
          formKey: _formKey,
          emailCtrl: _emailCtrl,
          isLoading: isLoading,
          onSend: _send,
        ),
      ),
    );
  }
}

class _FormState extends StatelessWidget {
  const _FormState({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Enter your email and we\'ll send you a reset link.',
            style: AppTypography.bodyL(),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: Validators.email,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          SortoButton(
            label: 'Send Reset Link',
            isLoading: isLoading,
            onPressed: isLoading ? null : onSend,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📬', style: TextStyle(fontSize: 64))
              .animate()
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1.0, 1.0),
                curve: Curves.elasticOut,
                duration: 700.ms,
              ),
          const SizedBox(height: 24),
          Text(
            'Check your inbox!',
            style: AppTypography.headingL(color: AppColors.darkTextPrimary),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'We sent you a link to reset your password.',
            style: AppTypography.bodyM(),
            textAlign: TextAlign.center,
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}
