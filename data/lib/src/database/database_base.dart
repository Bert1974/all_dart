import 'dart:async';
import 'dart:typed_data';

import 'package:data/data.dart';

import 'database_stub.dart'
    if (dart.library.io) 'database_noweb.dart'
    if (dart.library.js) 'database_web.dart';

enum DatabaseTypes { local, network }

abstract class Database {
  static bool? _hasStore;

  Database();

  Messages get messages;

  void dispose() {}

  factory Database.openNetwork(String server) => NetworkDatabase(server);

  static bool get checkStore => _hasStore ??= openStore_(null).result != null;

  //for server
  static Result<Database> openStore(String databasefile) => openStore_(databasefile);

  Database forLocaleTag(String localeTag);

  ByteData getReference() {
    throw UnsupportedError('wrong usage');
  }

  void setReference(ByteData reference) {
    throw UnsupportedError('wrong usage');
  }

  void seed() {
    throw UnsupportedError('wrong usage');
  }

  FutureOr<Result<bool>> open() async {
    throw UnimplementedError();
  }

  FutureOr<Result<User>> login(String name, String password) async {
    throw UnimplementedError();
  }

  Future<User?> checkToken(String name, String token) async {
    throw UnimplementedError();
  }

  Future<User?> check(User user) async {
    throw UnimplementedError();
  }

  Future<Result<bool>> saveUserSettings(
      User user, String type, Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

  FutureOr<Result<List<Server>>> getServers(User user) async {
    throw UnimplementedError();
  }

  FutureOr<Result<bool>> saveServer(User user, Server server) async {
    throw UnimplementedError();
  }
}
