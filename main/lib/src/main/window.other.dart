import 'package:flutter/material.dart';
import 'package:main/src/main/window.base.dart';

import 'app.dart';

/// The Widget that configures your application.
class MyWindow extends BaseMyWindow<MyWindow> {
  const MyWindow({super.key});

  @override
  State<MyWindow> createState() => _MyWindowState();
}

class _MyWindowState extends BaseMyWindowState<MyWindow> {
  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return const MyApp();
  }
}
