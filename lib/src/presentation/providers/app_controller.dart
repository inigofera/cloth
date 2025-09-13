import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App controller state
class AppState {
  final bool isLoading;
  final bool hasCompletedOnboarding;
  final bool isInitialized;

  const AppState({
    this.isLoading = true,
    this.hasCompletedOnboarding = false,
    this.isInitialized = false,
  });

  AppState copyWith({
    bool? isLoading,
    bool? hasCompletedOnboarding,
    bool? isInitialized,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// App controller notifier for managing app-wide state
class AppController extends Notifier<AppState> {
  @override
  AppState build() {
    return const AppState();
  }

  /// Initialize the app - always show welcome screen
  Future<void> initialize() async {
    // Always show welcome screen on app start
    state = state.copyWith(
      isLoading: false,
      hasCompletedOnboarding: false, // Always false to show welcome screen
      isInitialized: true,
    );
  }

  /// Mark onboarding as completed (navigate to home screen)
  Future<void> completeOnboarding() async {
    // Simply navigate to home screen - no persistence needed
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  /// Reset onboarding (show welcome screen again)
  Future<void> resetOnboarding() async {
    // Simply show welcome screen again
    state = state.copyWith(hasCompletedOnboarding: false);
  }
}

/// Provider for app controller
final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

/// Convenience providers
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appControllerProvider).isLoading;
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(appControllerProvider).hasCompletedOnboarding;
});

final isInitializedProvider = Provider<bool>((ref) {
  return ref.watch(appControllerProvider).isInitialized;
});
