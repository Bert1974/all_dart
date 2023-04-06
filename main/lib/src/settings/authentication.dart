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

/*
  post(String url, Map<String, dynamic> data) =>
      Network(baseUrl, token).postData(url, data);
*/
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

  login(BuildContext context, Login login) async {
    User? user = await _db.db!.login(login.name, login.password);

    if (user != null) {
      var login = LoginState.login(user);
      _value = login;
      notifyListeners();
      //    var location = GoRouter.of(context).location;
      //   var qp = GoRouterState.of(context).queryParam;
      //   if (queryParam.containes())
      //   notifyListeners();
      // ignore: use_build_context_synchronously
      context.go('/');
    }
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
  Database? db;
  DBHandler();

  static DBHandler of(BuildContext context) {
    return Provider.of<DBHandler>(context, listen: false);
  }

  open(DatabaseTypes type) async {
    Database? db_;

    switch (type) {
      case DatabaseTypes.local:
        db_ = Database.openStore();
        if (db_ == null) {
          return;
        }
        db?.dispose();
        db = null;
        await db_.open();
        break;
      case DatabaseTypes.network:
        db_ = Database.openNetwork();
        break;
    }
    db = db_;
    // User? user = await db_.login(login.name, login.password);
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