import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:main/main.dart';
import 'package:main/src/language.dart';
import 'package:main/src/settings/authentication.dart';
import 'package:main/src/settings/theme_controller.dart';
import 'package:main/src/widgets.dart';

enum MenuCmd { about, logout }

class AppPage extends StatefulWidget {
  final AppPageWidget child;

  const AppPage({super.key, required this.child});

  @override
  State<AppPage> createState() => AppPageState();
}

class AppPageState extends State<AppPage> {
  @override
  void initState() {
    super.initState();
    PageContext.of(context)?.register(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    PageContext.of(context)?.unregister(this);
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    PageContext.of(context)?.register(this);
  }

  @override
  Widget build(BuildContext context) {
    var auth = AuthenticationHandler.of(context);
    final themeController = ThemeController.of(context);
    //  final settings = UserSettingsHandler.of(context);
    //final auth = AuthenticationHandler.of(context);
    final translations = AppLocalizations.of(context)!;
    return ScaffoldMessenger(
        child: Scaffold(
            appBar: AppBar(
              title: widget.child.title(context),
              leading: Row(mainAxisSize: MainAxisSize.min, children: [
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
                AppPopupMenuButton<dynamic>(
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
                          if (auth.value.user == null)
                            PopupMenuItem<Language?>(
                                child: PopupMenuButton(
                              onSelected: (value) async {
                                if (value != null) {
                                  themeController.setLanguage(context, value);
                                }
                              },
                              child: Text(translations.mainpopupmenu_language),
                              itemBuilder: (_) {
                                return languages
                                    .map((l) => PopupMenuItem<Language?>(
                                        value: l, child: Text(l.description)))
                                    .toList();
                              },
                            )),
                          PopupMenuItem<MenuCmd?>(
                              value: MenuCmd.about,
                              child: Text(translations.mainpopupmenu_about)),
                          if (auth.value.user != null)
                            PopupMenuItem<MenuCmd?>(
                                value: MenuCmd.logout,
                                child: Text(translations.mainpopupmenu_logout))
                        ]),
              ],
            ),

            // To work with lists that may contain a large number of items, it’s best
            // to use the ListView.builder constructor.
            //
            // In contrast to the default ListView constructor, which requires
            // building all Widgets up front, the ListView.builder constructor lazily
            // builds Widgets as they’re scrolled into view.
            body: widget.child as Widget));
  }
}
