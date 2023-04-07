import 'package:flutter/material.dart';
import 'package:main/src/settings/theme_controller.dart';
import 'package:main/src/widgets.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsPage extends AppPageStatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget get title => const Text("Preferences");

  @override
  Widget build(BuildContext context) {
    // final UserSettingsHandler settings = UserSettingsHandler.of(context);
    final ThemeController themeController = ThemeController.of(context);
    return Padding(
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
            await themeController.updateThemeMode(value);
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
        ));
  }
}
