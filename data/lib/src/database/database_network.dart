import 'dart:async';

import 'package:data/data.dart';

class NetworkDatabase extends Database {
  String? _token;
  late final String baseUrl;
  late final Messages? _messages;

  @override
  Messages get messages => _messages!;

  NetworkDatabase(String baseUrl) {
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    /* if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {

    }*/
    // ignore: prefer_initializing_formals
    this.baseUrl = baseUrl;
    _messages = null;
  }

  NetworkDatabase._forLocaleTag(NetworkDatabase network, String localeTag)
      : baseUrl = network.baseUrl,
        _token = network._token {
    //
    _messages = localeTag.messages;
  }

  @override
  Database forLocaleTag(String localeTag) {
    return NetworkDatabase._forLocaleTag(this, localeTag);
  }

  Network _nw() {
    return Network(baseUrl, _token, _messages!);
  }

  @override
  FutureOr<Result<bool>> open() async {
    return Result.value(true);
  }

  @override
  FutureOr<Result<User>> login(String name, String password) async {
    var res =
        await _nw().postData('api/login', {'name': name, 'password': password});
    if (res.success) {
      _token = res.data['token'];
      var user = User.fromJson(res.data['user']);
      return Result.value(user);
    }
    return Result<User>.network(res);
  }

  @override
  Future<Result<bool>> saveUserSettings(
      User user, String type, Map<String, dynamic> data) async {
    var res =
        await _nw().postData('api/user/setting', {'type': type, 'data': data});

    if (res.success) {
      return Result.value(true);
    }
    return Result<bool>.network(res);
  }

  @override
  Future<User?> check(User user) async {
    var res = await _nw().postData('api/currentuser', {});
    if (res.success) {
      return User.fromJson(res.data['user']);
    }
    return null;
  }

  @override
  FutureOr<Result<List<Server>>> getServers(User user) async {
    var res = await _nw().postData('api/servers', {});
    if (res.success) {
      return Result.value((res.data as List<dynamic>)
          .map((json) => Server.fromJson(json))
          .toList());
    }
    return Result<List<Server>>.network(res);
  }

  @override
  FutureOr<Result<bool>> saveServer(User user, Server server) async {
    var res = await _nw().postData('api/save_server', server.toJson());
    if (res.success) {
      return Result.value(true);
    }
    return Result<bool>.network(res);
  }
}
