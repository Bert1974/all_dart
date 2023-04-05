import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:main/src/auth/login_page.dart';
import 'package:main/src/authentication.dart';
import 'package:main/src/main/app_page.dart';
import 'package:main/src/pages/settings_page.dart';
import 'package:main/src/pages/test_page.dart';

MaterialPage<void> createPage<T extends Widget>(
    BuildContext context, GoRouterState state, T child) {
  return MaterialPage<void>(
    key: state.pageKey,
    child: AppPage(child: child),
  );
}

String? checkAuthenticated(context, state) {
  if (AuthenticationHandler.of(context).value.token == null) {
    return '/login';
  }
  return null;
}

final appRouter = GoRouter(routes: [
  GoRoute(
      path: '/',
      redirect: checkAuthenticated,
      // builder: (context, state) => const LoginPage()
      pageBuilder: (context, state) =>
          createPage(context, state, const TestPage())),
  GoRoute(
      path: '/settings',
      redirect: checkAuthenticated,
      // builder: (context, state) => const SettingsView()
      pageBuilder: (context, state) =>
          createPage(context, state, const SettingsPage())),
  GoRoute(
      path: '/login',
      redirect: (context, state) {
        if (AuthenticationHandler.of(context).value.token != null) {
          return '/';
        }
        return null;
      },
      pageBuilder: (context, state) =>
          createPage(context, state, const LoginPage())),
]);
