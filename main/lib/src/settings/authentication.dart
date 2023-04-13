import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    Result<User> user = await _db.db!.login(login.name, login.password);

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
      User? user = await _db.db?.check(value.user!);
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
  Database? db;
  DBHandler();

  static DBHandler of(BuildContext context) =>
      Provider.of<DBHandler>(context, listen: false);

  FutureOr<Result<bool>> open(DatabaseTypes type, Map<String, dynamic> options,
      String localeTag) async {
    Database? db_;

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
    db = null;

    var r = await db_.forLocaleTag(localeTag).open();

    if (r.result ?? false) {
      _dbMain = db_;
      db = _dbMain!.forLocaleTag(localeTag);
      return r;
    }
    _dbMain?.dispose();
    _dbMain = null;
    return r;
    // User? user = await db_.login(login.name, login.password);
  }

  void updateLanguage(String localeTag) {
    db = _dbMain?.forLocaleTag(localeTag);
  }
}
/*Handler {
  final AuthenticationHandler auth;
  NetworkHandler(this.auth) {
    //
  }

  static NetworkHandler of(BuildContext context) =>
      Provider.of<NetworkHandler>(context, listen: false);

  FutureOr<NetworkResponse> postData(String url, Map<String, dynamic> data) =>
      Network(baseUrl, auth.value.token).postData(url, data);
}
*/