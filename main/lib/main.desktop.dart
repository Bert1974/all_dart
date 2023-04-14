import 'dart:io';

import 'package:flutter/material.dart';
import './src/main/window.desktop.dart' as window_dekstop;
import './src/main/window.other.dart' as window_other;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

late String _docdir;
String get documentsDirectory => _docdir;

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  //final network = NetworkService();
  //final settings = SettingsService(network);
  // final settingsController = SettingsController(settings); //UserSettingsService/

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  //await settingsController.loadSettings();

  WidgetsFlutterBinding.ensureInitialized();

  _docdir = (await getApplicationDocumentsDirectory()).path;
/*
  if ( Platform.isWindows){
    _docdir=Platform.user
  }*/

  if (!(Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    runApp(const window_other.MyWindow());
    return;
  }

  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  runApp(const window_dekstop.MyWindow());
}
