import 'package:flutter/material.dart';
import 'package:main/main.dart';

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
