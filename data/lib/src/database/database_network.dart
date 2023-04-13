import 'dart:async';

import 'package:data/data.dart';

class NetworkDatabase extends Database {
  String? _token;
  late final String baseUrl;
  late final Messages? messages;

  NetworkDatabase(String baseUrl) {
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    /* if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {

    }*/
    // ignore: prefer_initializing_formals
    this.baseUrl = baseUrl;
    messages = null;
  }

  NetworkDatabase._forLocaleTag(NetworkDatabase network, String localeTag)
      : baseUrl = network.baseUrl,
        _token = network._token {
    //
    messages = localeTag.messages;
  }

  @override
  Database forLocaleTag(String localeTag) {
    return NetworkDatabase._forLocaleTag(this, localeTag);
  }

  Network _nw() {
    return Network(baseUrl, _token, messages!);
  }

  @override
  FutureOr<Result<bool>> open() async {
    return Result.value(true);
  }

  @override
  FutureOr<Result<User>> login(String name, String password) async {
    var res =
        await _nw().postData('login', {'name': name, 'password': password});
    if (res.success) {
      _token = res.data['token'];
      var user = User.fromJson(res.data['user']);
      return Result.value(user);
    }
    return Result<User>.network(res);
  }

  @override
  Future<bool> saveUserSettings(
      User user, String type, Map<String, dynamic> data) async {
    var res =
        await _nw().postData('user/setting', {'type': type, 'data': data});

    return res.success;
  }

  @override
  Future<User?> check(User user) async {
    var res = await _nw().postData('currentuser', {});
    if (res.success) {
      return User.fromJson(res.data['user']);
    }
    return null;
  }

  @override
  Result<List<Server>> getServers(User user) {
    var res = await _nw().postData('getserver', {});
    if (res.success) {
      return User.fromJson(res.data['user']);
    }
    return null;
  }
  @override
  bool saveServer(User user, Server server) {}
}
