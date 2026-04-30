// lib/core/extensions/error_extensions.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

extension ErrorExtensions on Object {
  /// Converts an error/exception into a user-friendly message.
  String toUserFriendlyMessage() {
    if (this is AuthException) {
      final authException = this as AuthException;
      final message = authException.message.toLowerCase();

      if (message.contains('invalid login credentials') || message.contains('invalid credentials')) {
        return 'Wrong email or password. Please try again.';
      }
      if (message.contains('invalid password')) {
        return 'The password you entered is incorrect.';
      }
      if (message.contains('user not found')) {
        return 'No account found with this email.';
      }
      if (message.contains('email not confirmed')) {
        return 'Please confirm your email address before signing in.';
      }
      if (message.contains('user already registered')) {
        return 'An account with this email already exists.';
      }
      if (message.contains('rate limit exceeded')) {
        return 'Too many attempts. Please try again later.';
      }
      if (message.contains('network') || message.contains('connection')) {
        return 'Network error. Please check your internet connection.';
      }

      // If the message is already somewhat user-friendly, return it.
      // Otherwise, return a generic one.
      return authException.message;
    }

    if (this is Exception) {
      final msg = toString().toLowerCase();
      if (msg.contains('socketexception') || msg.contains('network')) {
        return 'Connection error. Please check your internet.';
      }
      return 'Something went wrong. Please try again.';
    }

    return 'An unexpected error occurred.';
  }
}

extension ContextErrorExtensions on BuildContext {
  /// Shows a user-friendly error snackbar.
  void showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          error.toUserFriendlyMessage(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows a success snackbar.
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
