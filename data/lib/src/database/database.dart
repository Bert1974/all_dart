import 'dart:async';
import 'dart:typed_data';

import 'package:data/src/network.dart';

import 'database_stub.dart'
    if (dart.library.io) 'database_noweb.dart'
    if (dart.library.js) 'database_web.dart';

import '../models/view_models.dart';

enum DatabaseTypes { local, network }

class NetworkDatabase extends Database {
  String? _token;
  var baseUrl = 'http://127.0.0.1:2222/';

  Network _nw() {
    return Network(baseUrl, _token);
  }

  @override
  FutureOr<void> open() async {}

  @override
  FutureOr<User?> login(String name, String password) async {
    var res =
        await _nw().postData('login', {'name': name, 'password': password});
    if (res.success) {
      _token = res.data['token'];
      var user = User.fromJson(res.data['user']);
      return user;
    }
    return null;
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
}

abstract class Database {
  static Database? _store;

  Database();

  factory Database.openNetwork() => NetworkDatabase();

  //for server
  static Database openStore() => (_store ??= openStore_())!;

/*  FutureOr<Database> forIsolate(ByteData reference) async {
    var result = _store!.setReference(reference)._(reference);
    return result;
  }*/

  ByteData getReference() {
    throw UnsupportedError('wrong usage');
  }

  void setReference(ByteData reference) {
    throw UnsupportedError('wrong usage');
  }

  void seed() {
    throw UnsupportedError('wrong usage');
  }

  FutureOr<void> open() async {
    return null;
  }

  FutureOr<User?> login(String name, String password) async {
    return null;
  }

  Future<User?> checkToken(String name, String token) async {
    return null;
  }

  Future<User?> check(User user) async {
    return null;
  }

  Future<bool> saveUserSettings(
      User user, String type, Map<String, dynamic> data) async {
    return false;
  }
}
