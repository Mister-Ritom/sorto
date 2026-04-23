// lib/features/onboarding/onboarding_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { poster, performer, both }

class OnboardingState {
  final UserRole? role;
  final List<String> selectedCategories;
  final String username;
  final bool notificationsGranted;
  final bool onboardingComplete;
  final int currentStep;

  const OnboardingState({
    this.role,
    this.selectedCategories = const [],
    this.username = '',
    this.notificationsGranted = false,
    this.onboardingComplete = false,
    this.currentStep = 0,
  });

  OnboardingState copyWith({
    UserRole? role,
    List<String>? selectedCategories,
    String? username,
    bool? notificationsGranted,
    bool? onboardingComplete,
    int? currentStep,
  }) =>
      OnboardingState(
        role: role ?? this.role,
        selectedCategories: selectedCategories ?? this.selectedCategories,
        username: username ?? this.username,
        notificationsGranted: notificationsGranted ?? this.notificationsGranted,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        currentStep: currentStep ?? this.currentStep,
      );
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setRole(UserRole role) => state = state.copyWith(role: role);

  void toggleCategory(String category) {
    final current = List<String>.from(state.selectedCategories);
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    state = state.copyWith(selectedCategories: current);
  }

  void setUsername(String username) => state = state.copyWith(username: username);

  void setNotificationsGranted(bool granted) =>
      state = state.copyWith(notificationsGranted: granted);

  void completeOnboarding() =>
      state = state.copyWith(onboardingComplete: true);

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);

  bool get hasMinimumCategories => state.selectedCategories.isNotEmpty;
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);
