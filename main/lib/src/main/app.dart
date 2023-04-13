import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:main/src/settings/authentication.dart';
import 'package:main/src/main/go_router.dart';
import 'package:main/src/settings/user_settings_handler.dart';
import 'package:provider/provider.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _db = DBHandler();
  late final _auth = AuthenticationHandler(_db);
  late final _settings = UserSettingsHandler(_db, _auth);

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  void _init() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(lazy: true, create: (context) => _auth),
          Provider(lazy: true, create: (context) => _settings),
          Provider(lazy: true, create: (context) => _db),
          ChangeNotifierProvider(
            lazy: true,
            create: (context) => _settings.themeController,
          )
        ],
        builder: (context, child) {
          return /*ValueListenableBuilder(
              valueListenable: _auth,
              builder: (context, state, diget) =>*/
              AnimatedBuilder(
            animation: _auth, //_settings.themeController,
            builder: (BuildContext context, Widget? child) {
              return MaterialApp.router(
                // Providing a restorationScopeId allows the Navigator built by the
                // MaterialApp to restore the navigation stack when a user leaves and
                // returns to the app after it has been killed while running in the
                // background.
                restorationScopeId: 'app',

                // Provide the generated AppLocalizations to the MaterialApp. This
                // allows descendant Widgets to display the correct translations
                // depending on the user's locale.
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                locale: _settings.themeController.language?.locale,
                supportedLocales: const [
                  Locale('en', ''), // English, no
                  Locale('nl', ''), // Dutchcountry code
                ],

                // Use AppLocalizations to configure the correct application title
                // depending on the user's locale.
                //
                // The appTitle is defined in .arb files found in the localization
                // directory.
                onGenerateTitle: (BuildContext context) =>
                    AppLocalizations.of(context)!.appTitle,

                // Define a light and dark color theme. Then, read the user's
                // preferred ThemeMode (light, dark, or system default) from the
                // SettingsController to display the correct theme.
                theme: ThemeData(),
                darkTheme: ThemeData.dark(),
                themeMode: _settings.themeController.themeMode,
                debugShowCheckedModeBanner: false,

                /* routeInformationParser:
                        appRouter.routeInformationParser,
                        routerDelegate: appRouter.routerDelegate,
                        routeInformationProvider:
                        appRouter.routeInformationProvider,
                        backButtonDispatcher: appRouter.backButtonDispatcher,
*/
                routerConfig: appRouter,
              );
            },
          );
        });
  }
}
