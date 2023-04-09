import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:main/src/settings/authentication.dart';
import 'package:main/src/settings/theme_controller.dart';
import 'package:main/src/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends AppPageStatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget title(BuildContext context) =>
      Text(AppLocalizations.of(context)!.appPreferences);

  @override
  Widget build(BuildContext context) {
    // final UserSettingsHandler settings = UserSettingsHandler.of(context);
    final ThemeController themeController = ThemeController.of(context);
    final translations = AppLocalizations.of(context)!;
    return ValueListenableBuilder(
        valueListenable: Provider.of<AuthenticationHandler>(context),
        builder: (context, loginState, widget) => Column(children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  // Glue the SettingsController to the theme selection DropdownButton.
                  //
                  // When a user selects a theme from the dropdown list, the
                  // SettingsController is updated, which rebuilds the MaterialApp.
                  child: DropdownButton<ThemeMode>(
                    // Read the selected themeMode from the controller
                    value: themeController.themeMode,
                    // Call the updateThemeMode method any time the user selects a theme.
                    onChanged: (value) async {
                      if (value != null) {
                        if (!await themeController.updateThemeMode(value)) {
                          // ignore: use_build_context_synchronously
                          showSnackError(context, translations.errorSaving);
                        }
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      )
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.all(16),
                  // Glue the SettingsController to the theme selection DropdownButton.
                  //
                  // When a user selects a theme from the dropdown list, the
                  // SettingsController is updated, which rebuilds the MaterialApp.
                  child: DropdownButton<Language>(
                    // Read the selected themeMode from the controller
                    value: themeController.language,
                    // Call the updateThemeMode method any time the user selects a theme.
                    onChanged: (value) async {
                      if (value != null) {
                        if (!(await themeController.updateLocale(value))) {
                          // ignore: use_build_context_synchronously
                          showSnackError(context, translations.errorSaving);
                        }
                      }
                    },
                    items: languages
                        .map((l) => DropdownMenuItem<Language>(
                              value: l,
                              child: Text(l.description),
                            ))
                        .toList(),
                  ))
            ]));
  }
}
