// lib/core/utils/validators.dart
import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static final _usernameRegex = RegExp(r'^[a-z0-9_\.]+$');
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');

  static String? username(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    if (value.length < AppConstants.usernameMinLength) {
      return 'At least ${AppConstants.usernameMinLength} characters';
    }
    if (value.length > AppConstants.usernameMaxLength) {
      return 'Max ${AppConstants.usernameMaxLength} characters';
    }
    if (!_usernameRegex.hasMatch(value.toLowerCase())) {
      return 'Only letters, numbers, underscores and dots';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final base = password(value);
    if (base != null) return base;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? dareTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length < 10) return 'At least 10 characters';
    if (value.length > AppConstants.dareTitleMaxLength) {
      return 'Max ${AppConstants.dareTitleMaxLength} characters';
    }
    return null;
  }

  static String? dareDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'Description is required';
    if (value.trim().length < 20) return 'At least 20 characters';
    if (value.length > AppConstants.dareDescriptionMaxLength) {
      return 'Max ${AppConstants.dareDescriptionMaxLength} characters';
    }
    return null;
  }

  static String? rejectionReason(String? value) {
    if (value == null || value.trim().isEmpty) return 'Reason is required';
    if (value.trim().length < AppConstants.minRejectionReasonLength) {
      return 'Explain in at least ${AppConstants.minRejectionReasonLength} characters';
    }
    return null;
  }

  static String? upiId(String? value) {
    if (value == null || value.isEmpty) return 'UPI ID is required';
    if (!_upiRegex.hasMatch(value)) return 'Enter a valid UPI ID (e.g. name@upi)';
    return null;
  }

  static String? withdrawalAmount(String? value, int available) {
    if (value == null || value.isEmpty) return 'Enter amount';
    final amount = int.tryParse(value);
    if (amount == null) return 'Enter a valid number';
    if (amount < AppConstants.minWithdrawalCoins) {
      return 'Minimum ${AppConstants.minWithdrawalCoins} coins';
    }
    if (amount > available) return 'Insufficient earned balance';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
