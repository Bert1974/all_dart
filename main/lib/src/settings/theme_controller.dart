import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/src/settings/user_settings_handler.dart';
import 'package:provider/provider.dart';

class ThemeSettings {
  late ThemeMode _themeMode;

  ThemeSettings() {
    _themeMode = ThemeMode.dark;
  }

  void update(Map<String, dynamic> json) {
    _themeMode = ThemeMode.values[json['theme']];
  }
/* ThemeSettings.fromJSon(Map<String, dynamic> json)
      : _themeMode = ThemeMode.values.byName(json['theme']);*/

  Map<String, dynamic> toJson() => {'theme': _themeMode.index};
}

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class ThemeController with ChangeNotifier {
  final UserSettingsHandler settingHandler;
  ThemeController(this.settingHandler);

  final ThemeSettings settings = ThemeSettings();

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => settings._themeMode;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  void loadSettings() {
    var current = settingHandler.settings(UserSettingTypes.theme);
    if (current != null) {
      settings.update(current);
      notifyListeners();
    }
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == settings._themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    // settings._themeMode = newThemeMode;

    if (await settingHandler.updateSettings(UserSettingTypes.theme,
        (ThemeSettings().._themeMode = newThemeMode).toJson())) {
      //_auth.refresh() has been called
    }
  }

  static ThemeController of(BuildContext context) =>
      Provider.of<UserSettingsHandler>(context, listen: false).themeController;
}
