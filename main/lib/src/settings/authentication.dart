import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:main/main.dart';
import 'package:provider/provider.dart';

bool isAuthenticated(BuildContext context) =>
    AuthenticationHandler.of(context).value.user != null;

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
    Result<User> user = await _db.login(login.name, login.password);

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
      User? user = await _db.checkUser(value.user!);
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
