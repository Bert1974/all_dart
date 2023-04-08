import 'package:flutter/material.dart';
import 'package:main/src/main/app_page.dart';
import 'package:main/src/settings/theme_controller.dart';
import 'package:provider/provider.dart';

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
