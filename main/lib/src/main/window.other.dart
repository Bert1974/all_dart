import 'package:flutter/material.dart';
import 'package:main/src/settings/settings_controller.dart';

import 'app.dart';

/// The Widget that configures your application.
class MyWindow extends StatefulWidget {
  const MyWindow({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyWindow> createState() => _MyWindowState();
}

class _MyWindowState extends State<MyWindow> {
  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return MyApp(
      settingsController: widget.settingsController,
    );
  }
}
