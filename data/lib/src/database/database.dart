import 'dart:async';
import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:data/src/localization/messages_nl.i18n.dart';

import 'database_stub.dart'
    if (dart.library.io) 'database_noweb.dart'
    if (dart.library.js) 'database_web.dart';

enum DatabaseTypes { local, network }

class Result<T> {
  final T? result;
  final String? error;

  Result._({this.result, this.error});

  factory Result.value(T result) => Result._(result: result);
  factory Result.error(String error) => Result._(error: error);
  factory Result.network(NetworkResponse res) => Result._(error: res.message);
}

class MessagesHelper {
  static final List<Messages> _languages = [
    const Messages(),
    const MessagesNl(),
  ];
  static Messages forLocale(String? languageCode) =>
      languageCode == null || languageCode.isEmpty
          ? getDefault()
          : _languages.singleWhere(
              (element) => element.languageCode.startsWith(languageCode),
              orElse: () => getDefault());

  static Messages getDefault() => _languages[0];
}

extension MessagesStringExtension on String {
  Messages get messages => MessagesHelper.forLocale(this);
  NetworkMessages get network => messages.network;
}

abstract class Database {
  Database();

  void dispose() {}

  factory Database.openNetwork(String server) => NetworkDatabase(server);

  static bool get checkStore => openStore_(null) != null;

  //for server
  static Database? openStore(String databasefile) => openStore_(databasefile);

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

  Future<bool> saveUserSettings(
      User user, String type, Map<String, dynamic> data) async {
    throw UnimplementedError();
  }
}
