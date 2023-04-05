import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:main/src/settings/settings_controller.dart';
import 'package:provider/provider.dart';

import 'app.dart';

/// The Widget that configures your application.
class BaseMyWindow<T extends BaseMyWindow<T>> extends StatefulWidget {
  const BaseMyWindow({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<T> createState() => BaseMyWindowState<T>();
}

class BaseMyWindowState<T extends BaseMyWindow<T>> extends State<T> {
  final pageContext = PageContext();

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => pageContext,
        child: MyApp(
          settingsController: widget.settingsController,
        ));
  }

  askClose(void Function() doExit) {
    // ignore: use_build_context_synchronously
    showDialog(
      context: pageContext.context!,
      builder: (_) {
        return AlertDialog(
          title: const Text('Are you sure you want to close this window?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(pageContext.context!).pop();
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
}
