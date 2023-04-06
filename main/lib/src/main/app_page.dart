import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:main/main.dart';
import 'package:main/src/settings/authentication.dart';
import 'package:provider/provider.dart';

enum MenuCmd { about, logout }

class AppPage extends StatelessWidget {
  final Widget child;

  const AppPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Provider.of<PageContext?>(context)?.context = context;
    var auth = AuthenticationHandler.of(context);
    return ScaffoldMessenger(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Sample Items'),
              leading: Row(children: [
                if (Navigator.canPop(context))
                  IconButton(
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
                PopupMenuButton<MenuCmd?>(
                    padding: EdgeInsets.zero,
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
              ]),
              actions: [
                if (auth.value.user != null)
                  IconButton(
                    icon: const Icon(Icons.settings),
                    padding: EdgeInsets.zero,
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
            body: child));
  }
}
