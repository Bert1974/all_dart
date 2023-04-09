import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:main/src/auth/login_page.dart';
import 'package:main/src/settings/authentication.dart';
import 'package:main/src/main/app_page.dart';
import 'package:main/src/pages/settings_page.dart';
import 'package:main/src/pages/test_page.dart';
import 'package:main/src/widgets.dart';

MaterialPage<void> _createPage<T extends AppPageWidget>(
    BuildContext context, GoRouterState state, T child) {
  return MaterialPage<void>(
    key: state.pageKey,
    child: AppPage(child: child),
  );
}

String? _checkAuthenticated(context, state) {
  if (AuthenticationHandler.of(context).value.user == null) {
    return '/login';
  }
  return null;
}

final appRouter = MyRouter();

class MyRouter extends GoRouter {
  MyRouter()
      : super(routes: [
          GoRoute(
              path: '/',
              redirect: _checkAuthenticated,
              // builder: (context, state) => const LoginPage()
              pageBuilder: (context, state) =>
                  _createPage(context, state, const TestPage())),
          GoRoute(
              path: '/settings',
              redirect: _checkAuthenticated,
              // builder: (context, state) => const SettingsView()
              pageBuilder: (context, state) =>
                  _createPage(context, state, const SettingsPage())),
          GoRoute(
              path: '/login',
              redirect: (context, state) {
                if (AuthenticationHandler.of(context).value.user != null) {
                  return '/';
                }
                return null;
              },
              pageBuilder: (context, state) =>
                  _createPage(context, state, const LoginPage())),
        ]);
}
