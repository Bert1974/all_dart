import 'dart:io';

import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:main/src/main/window.base.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

/// The Widget that configures your application.
class MyWindow extends BaseMyWindow<MyWindow> {
  const MyWindow({super.key});

  @override
  State<MyWindow> createState() => _MyWindowState();
}

class _MyWindowState extends BaseMyWindowState<MyWindow> with WindowListener {
  final _pageContext = PageContext();

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => _pageContext,
        lazy: true,
        child: super.build(context));
  }

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
      _askClose(() {
        exit(0);
      });
    }
  }

  _askClose(void Function() doExit) {
    // ignore: use_build_context_synchronously
    showDialog(
      context: _pageContext.context!,
      builder: (_) {
        return AlertDialog(
          title: const Text('Are you sure you want to close this window?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(_pageContext.context!).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                doExit();
                // Navigator.pop(_pageContext.context!);
                //    /*await*/ windowManager.destroy();
              },
            ),
          ],
        );
      },
    );
  }

  GlobalKey mainKey = GlobalKey();
}
