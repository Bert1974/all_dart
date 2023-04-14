import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:main/main.dart';
import 'package:main/src/settings/theme_controller.dart';
import 'package:provider/provider.dart';

class LoginState {
  User? user;

  LoginState._(this.user);

  static login(User user) {
    return LoginState._(user);
  }

  static logout() {
    return LoginState._(null);
  }

  LoginState updateUser(User user) {
    return LoginState._(user);
  }
}

class AuthenticationHandler extends ChangeNotifier
    implements ValueListenable<LoginState> {
  LoginState _value;
  final DBHandler _db;
  AuthenticationHandler(DBHandler db)
      : _value = LoginState.logout(),
        _db = db;

  static AuthenticationHandler of(BuildContext context) {
    return Provider.of<AuthenticationHandler>(context, listen: false);
  }

  FutureOr<Result<User>> login(BuildContext context, Login login) async {
    Result<User> user = await _db._db!.login(login.name, login.password);

    if (user.result != null) {
      var login = LoginState.login(user.result!);
      _value = login;
      notifyListeners();
      //    var location = GoRouter.of(context).location;
      //   var qp = GoRouterState.of(context).queryParam;
      //   if (queryParam.containes())
      //   notifyListeners();
      // ignore: use_build_context_synchronously
      context.go('/');
    }
    return user;
  }

  FutureOr<void> refresh() async {
    if (value.user != null) {
      User? user = await _db._db?.check(value.user!);
      if (user != null) {
        var login = _value.updateUser(user);
        _value = login;
        notifyListeners();
        //   context.go('/');
      }
    }
  }

  @override
  LoginState get value => _value;

  logout(BuildContext context) {
    var login = LoginState.logout();
    _value = login;
    context.go('/login');
  }
}

class DBHandler {
  Database? _dbMain;
  Database? _db;
  AppLocalizations? _translations;
  DBHandler();

//  get

  static DBHandler of(BuildContext context) =>
      Provider.of<DBHandler>(context, listen: false);

  FutureOr<Result<bool>> open(
    BuildContext context,
    DatabaseTypes type,
    Map<String, dynamic> options,
  ) async {
    var themeController = ThemeController.of(context);
    Database? db_;

    _translations = AppLocalizations.of(context)!;

    switch (type) {
      case DatabaseTypes.local:
        db_ = Database.openStore(options['database']);
        break;
      case DatabaseTypes.network:
        db_ = Database.openNetwork(options['server']);
        break;
    }
    if (db_ == null) {
      return Result.value(false);
    }
    _dbMain?.dispose();
    _dbMain = null;
    _db = null;

    var r = await db_.forLocaleTag(themeController.localeTag).open();

    if (r.result ?? false) {
      _dbMain = db_;
      _db = _dbMain!.forLocaleTag(themeController.localeTag);
      return r;
    }
    _dbMain?.dispose();
    _dbMain = null;
    return r;
    // User? user = await db_.login(login.name, login.password);
  }

  void updateLanguage(BuildContext context, String localeTag) {
    _db = _dbMain?.forLocaleTag(localeTag);
    _translations = AppLocalizations.of(context)!;
  }

  Future<Result<T>> _dbcall<T>(
      User? user, Future<Result<T>> Function() action) async {
    if (_db != null) {
      if (user != null) {
        return await action();
      }
      return Result<T>.error(_db!.messages.general.unauthenticated);
    }
    return Result<T>.error(_translations!.notLoggedIn);
  }

  Future<Result<List<Server>>> getServers(User? user) async {
    return await _dbcall(user, () async => await _db!.getServers(user!));
  }

  Future<Result<bool>> saveUserSettings(
      User user, String type, Map<String, dynamic> data) async {
    return await _dbcall<bool>(
        user, () async => await _db!.saveUserSettings(user, type, data));
  }
}
