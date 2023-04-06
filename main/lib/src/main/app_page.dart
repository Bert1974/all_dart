import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:main/main.dart';
import 'package:main/src/settings/authentication.dart';
import 'package:main/src/widgets.dart';

enum MenuCmd { about, logout }

class AppPage extends StatefulWidget {
  final Widget child;

  const AppPage({super.key, required this.child});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  @override
  void initState() {
    super.initState();
    PageContext.of(context).context = context;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var auth = AuthenticationHandler.of(context);
    return ScaffoldMessenger(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Sample Items'),
              leading: Row(children: [
                AppPopupMenuButton<MenuCmd?>(
                    icon: const Icon(Icons.menu),
                    onSelected: (value) async {
                      switch (value) {
                        case MenuCmd.logout:
                          {
                            await auth.logout(context);
                          }
                          break;
                        default:
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                          const PopupMenuItem<MenuCmd?>(
                              value: MenuCmd.about, child: Text("About")),
                          if (auth.value.user != null)
                            const PopupMenuItem<MenuCmd?>(
                                value: MenuCmd.logout, child: Text("Log out"))
                        ]),
                if (Navigator.canPop(context))
                  AppIconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () async {
                      /* if (false) {
                      
                    } else {*/
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else if (auth.value.user != null) {
                        await auth.logout(context);
                      } else {
                        ;
                      }
                      //   }
                    },
                  ),
              ]),
              actions: [
                if (auth.value.user != null &&
                    GoRouter.of(context).location != '/settings')
                  AppIconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Navigate to the settings page. If the user leaves and returns
                      // to the app after it has been killed while running in the
                      // background, the navigation stack is restored.
                      context.push('/settings');
                    },
                  ),
              ],
            ),

            // To work with lists that may contain a large number of items, it’s best
            // to use the ListView.builder constructor.
            //
            // In contrast to the default ListView constructor, which requires
            // building all Widgets up front, the ListView.builder constructor lazily
            // builds Widgets as they’re scrolled into view.
            body: widget.child));
  }
}
