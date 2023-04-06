import 'dart:io';

import 'package:flutter/material.dart';
import 'package:main/src/main/window.base.dart';
import 'package:window_manager/window_manager.dart';

/// The Widget that configures your application.
class MyWindow extends BaseMyWindow<MyWindow> {
  const MyWindow({super.key});

  @override
  State<MyWindow> createState() => _MyWindowState();
}

class _MyWindowState extends BaseMyWindowState<MyWindow> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    _init();
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  Future<void> onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();

    if (isPreventClose) {
      askClose(() {
        exit(0);
      });
    }
  }

  GlobalKey mainKey = GlobalKey();
}
