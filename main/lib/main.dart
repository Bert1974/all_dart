import 'package:flutter/material.dart';
import 'package:main/src/main/app_page.dart';
import 'package:main/src/settings/theme_controller.dart';
import 'package:provider/provider.dart';

import 'src/settings/authentication.dart';

export 'main.stub.dart'
    if (dart.library.io) 'main.desktop.dart'
    if (dart.library.js) 'main.web.dart';

class PageContext {
  final List<AppPageState> _pages = [];

  static PageContext? of(BuildContext context) =>
      Provider.of<PageContext?>(context, listen: false);

  void register(AppPageState state) {
    if (!_pages.contains(state)) {
      _pages.add(state);
    }
  }

  void unregister(AppPageState state) {
    if (_pages.contains(state)) {
      _pages.remove(state);
    }
  }

  BuildContext? get context {
    return _pages
        // ignore: unnecessary_cast
        .map((e) => e as AppPageState?)
        .firstWhere((element) => element!.mounted, orElse: () => null)
        ?.context;
  }
}

class Language {
  final String description;
  final Locale locale;

  const Language(this.locale, this.description);

  @override
  bool operator ==(Object other) =>
      other is Language &&
      description == other.description &&
      locale.languageCode == other.locale.languageCode &&
      locale.countryCode == other.locale.countryCode;

  @override
  int get hashCode => description.hashCode ^ locale.hashCode;

  static Language? fromJson(Map<String, dynamic>? json) => json == null
      ? null
      :
      // ignore: unnecessary_cast
      languages.map<Language?>((e) => e as Language?).singleWhere(
              (element) =>
                  element!.locale.languageCode == json['language'] &&
                  element.locale.countryCode == json['country'],
              orElse: () => null) ??
          languages[0];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'language': locale.languageCode,
        'country': locale.countryCode
      };
}

List<Language> languages = const [
  Language(Locale('nl', ''), "Nederlands"),
  Language(Locale('en', ''), "English"),
];
/*
Language forLocale(Locale locale) {
  return languages.singleWhere((l) =>
          l.locale.languageCode ==
          locale
              .countryCode /*&&
      l.locale.languageCode == locale.languageCode*/
      );
}
*/
bool isAuthenticated(BuildContext context) =>
    AuthenticationHandler.of(context).value.user != null;

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
/*            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Some code to undo the change.
              },
            ),*/
  ));
}

void showSnackError(BuildContext context, String text) {
  final theme = Theme.of(context);
  final ThemeController themeController = ThemeController.of(context);
  final snackBarTheme = theme.themeSnackbarError(themeController.themeMode);

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: snackBarTheme.backgroundColor,
    actionOverflowThreshold: snackBarTheme.actionOverflowThreshold,
    closeIconColor: snackBarTheme.closeIconColor,
    margin: snackBarTheme.insetPadding,
    shape: snackBarTheme.shape,
    width: snackBarTheme.width,
    content: Text(text),
  ));
}

extension SnackBarThemeDataExtension on ThemeData {
  SnackBarThemeData themeSnackbarError(ThemeMode themeMode) {
    return snackBarTheme.copyWith(backgroundColor: Colors.red);
  }
}
