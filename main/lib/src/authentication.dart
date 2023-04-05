import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:main/main.dart';
import 'package:provider/provider.dart';

class LoginState {
  String? token;
  User? user;

  LoginState._(this.user, this.token);

  static login(User user, String token) {
    return LoginState._(user, token);
  }

  static logout() {
    return LoginState._(null, null);
  }

  post(String url, Map<String, dynamic> data) =>
      Network(baseUrl, token).postData(url, data);
}

class AuthenticationHandler extends ChangeNotifier
    implements ValueListenable<LoginState> {
  LoginState _value;
  AuthenticationHandler() : _value = LoginState.logout();

  static AuthenticationHandler of(BuildContext context) {
    return Provider.of<AuthenticationHandler>(context, listen: false);
  }

  login(BuildContext context, Map<String, dynamic> data) async {
    var res = await Network(baseUrl, value.token).postData('login', data);
    if (res.success) {
      var login =
          LoginState.login(User.fromJson(res.data['user']), res.data['token']);
      _value = login;
      //    var location = GoRouter.of(context).location;
      //   var qp = GoRouterState.of(context).queryParam;
      //   if (queryParam.containes())
      //   notifyListeners();
      // ignore: use_build_context_synchronously
      context.go('/');
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
