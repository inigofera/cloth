import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings state model
class SettingsState {
  final bool dailyReminders;
  final bool weeklyInsights;
  final bool autoSaveDrafts;
  final String defaultView;
  final String themeMode;
  final String accentColor;
  final bool compactView;
  final String gridSize;
  final bool analytics;

  const SettingsState({
    this.dailyReminders = true,
    this.weeklyInsights = false,
    this.autoSaveDrafts = true,
    this.defaultView = 'clothing',
    this.themeMode = 'system',
    this.accentColor = 'deepPurple',
    this.compactView = false,
    this.gridSize = 'medium',
    this.analytics = true,
  });

  SettingsState copyWith({
    bool? dailyReminders,
    bool? weeklyInsights,
    bool? autoSaveDrafts,
    String? defaultView,
    String? themeMode,
    String? accentColor,
    bool? compactView,
    String? gridSize,
    bool? analytics,
  }) {
    return SettingsState(
      dailyReminders: dailyReminders ?? this.dailyReminders,
      weeklyInsights: weeklyInsights ?? this.weeklyInsights,
      autoSaveDrafts: autoSaveDrafts ?? this.autoSaveDrafts,
      defaultView: defaultView ?? this.defaultView,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      compactView: compactView ?? this.compactView,
      gridSize: gridSize ?? this.gridSize,
      analytics: analytics ?? this.analytics,
    );
  }
}

/// Settings notifier for managing app settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void updateDailyReminders(bool value) {
    state = state.copyWith(dailyReminders: value);
  }

  void updateWeeklyInsights(bool value) {
    state = state.copyWith(weeklyInsights: value);
  }

  void updateAutoSaveDrafts(bool value) {
    state = state.copyWith(autoSaveDrafts: value);
  }

  void updateDefaultView(String value) {
    state = state.copyWith(defaultView: value);
  }

  void updateThemeMode(String value) {
    state = state.copyWith(themeMode: value);
  }

  void updateAccentColor(String value) {
    state = state.copyWith(accentColor: value);
  }

  void updateCompactView(bool value) {
    state = state.copyWith(compactView: value);
  }

  void updateGridSize(String value) {
    state = state.copyWith(gridSize: value);
  }

  void updateAnalytics(bool value) {
    state = state.copyWith(analytics: value);
  }
}

/// Provider for settings state
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

/// Convenience providers for specific settings
final dailyRemindersProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).dailyReminders;
});

final weeklyInsightsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).weeklyInsights;
});

final autoSaveDraftsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).autoSaveDrafts;
});

final defaultViewProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).defaultView;
});

final themeModeProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

final accentColorProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).accentColor;
});

final compactViewProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).compactView;
});

final gridSizeProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).gridSize;
});

final analyticsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).analytics;
});
