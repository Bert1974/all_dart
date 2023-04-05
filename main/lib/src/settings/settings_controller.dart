import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_service.dart';

class Settings {
  late ThemeMode _themeMode;

  Settings() {
    _themeMode = ThemeMode.dark;
  }
}

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(settingsService) : _settingsService = settingsService;

  final Settings settings = Settings();

  final SettingsService _settingsService;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => settings._themeMode;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == settings._themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    settings._themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    _settingsService.updateSettings(settings);
  }

  static SettingsController of(BuildContext context) =>
      Provider.of<SettingsController>(context, listen: false);
}
