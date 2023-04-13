import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/src/language.dart';
import 'package:main/src/settings/user_settings_handler.dart';
import 'package:provider/provider.dart';

class ThemeSettings {
  late ThemeMode _themeMode;
  late Language? _language;

  ThemeSettings() {
    _themeMode = ThemeMode.system;
    _language = null;
  }

  ThemeSettings clone() {
    var r = ThemeSettings();
    r._themeMode = _themeMode;
    r._language = _language;
    return r;
  }

  void update(Map<String, dynamic> json) {
    _themeMode = ThemeMode.values[json['theme']];
    _language = Language.fromJson(json['locale']);
  }
/* ThemeSettings.fromJSon(Map<String, dynamic> json)
      : _themeMode = ThemeMode.values.byName(json['theme']);*/

  Map<String, dynamic> toJson() =>
      {'theme': _themeMode.index, 'locale': _language?.toJson()};
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

  Language? get language => settings._language;
  String get localeTag => settings._language?.toLanguageTag() ?? 'en';

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
  FutureOr<bool> updateThemeMode(ThemeMode newThemeMode) async {
    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == settings._themeMode) return true;

    if (await settingHandler.updateSettings(UserSettingTypes.theme,
        (settings.clone().._themeMode = newThemeMode).toJson())) {
      //_auth.refresh() has been called
      return true;
    }
    return false;
  }

  /// Update and persist the ThemeMode based on the user's selection.
  FutureOr<bool> updateLocale(Language? newLanguage) async {
    if (newLanguage == null) {
      if (settings._language == null) {
        return true;
      }
    } else if (newLanguage == settings._language) {
      return true;
    }
    // Otherwise, store the
    if (await settingHandler.updateSettings(UserSettingTypes.theme,
        (settings.clone().._language = newLanguage).toJson())) {
      //_auth.refresh() has been called
      return true;
    }
    return false;
  }

  static ThemeController of(BuildContext context) =>
      Provider.of<UserSettingsHandler>(context, listen: false).themeController;
}
