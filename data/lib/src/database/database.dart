import 'dart:async';
import 'dart:typed_data';

import 'package:data/src/network.dart';

import 'database_stub.dart'
    if (dart.library.io) 'database_noweb.dart'
    if (dart.library.js) 'database_web.dart';

import '../models/view_models.dart';

class NetworkDatabase extends Database {
  String? _token;

  Network _nw() {
    return Network('http://127.0.0.1:2000', _token);
  }

  @override
  FutureOr<void> open() async {}

  @override
  FutureOr<User?> login(String name, String password) async {
    var res =
        await _nw().postData('/login', {'name': name, 'password': password});

    if (res.success) {
      _token = res.data['token'];
      return null;
    }
    return null;
  }
}

abstract class Database {
  static Database? _store;

  //for server
  static Database openStore() => _store ??= openStore_();

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
}
