import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: implementation_imports
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:data/data.dart';
import 'package:server/src/localization/servermessages.i18n.dart';

const configFileName = 'config.json';

late final String secretPassphrase;
late final String databaseDirectory;
late final int serverPort;
late final String serverUrl;
late final String? webdir;

response(String message, dynamic data, bool success) {
  return <String, dynamic>{
    'data': data,
    'message': message,
    'success': success
  };
}

class ServerException {
  final String message;

  ServerException(this.message);
}

responseOk() => response('Ok', null, true);
responseError(String? message) =>
    response(message ?? "Server error", null, false);
responseException(e) {
  /* if (e is ServerException) {
    return response(e.message, null, false);
  }*/
  return response("Server error", null, false);
}

responseData(dynamic data) => response("Ok", data, true);

responseResult<T>(Result<T> result, dynamic Function(T data) convert) {
  if (result.result != null) {
    return responseData(convert(result.result as dynamic));
  }
  return responseError(result.error);
}

Future<Result<User>> getUser(Database connection, HttpRequest req) async {
  var header = req.headers.value('Authorization');
  if (header?.startsWith('Bearer ') ?? false) {
    var token = header!.substring(7);
    try {
      // Verify a token
      final jwt = JWT.verify(token, SecretKey(secretPassphrase));
      var userName = jwt.payload['id'];
      var user = await connection.checkToken(userName, token);
      if (user != null) {
        return Result.value(user);
      }
      throw ServerException('JWT verify fout');
    } on JWTExpiredError {
      throw ServerException('JWT verlopen');
    } on JWTError {
      throw ServerException('JWT fout'); // ex: invalid signature
    }
  }
  throw ServerException('Geen toegang');
}

late final Database connection;

Database getConnection(HttpRequest req) {
  var header = req.headers.value('accept-language');
  if (header != null) {
    return connection.forLocaleTag(header);
  }
  return connection;
}

Servermessages getMessages(HttpRequest req) {
  var header = req.headers.value('accept-language');
  if (header != null) {
    return Servermessages();
  }
  return Servermessages();
}

extension JsonListExtenstension<T> on List<T> {
  List<Map<String, dynamic>> toJSon() =>
      map((i) => (i as dynamic).toJSon() as Map<String, dynamic>).toList();
}

Future<String?> checkDir(String? path) async {
  if (path != null && path.isNotEmpty) {
    return await Directory(path).exists() ? path : null;
  }
  return null;
}

Future<Result<bool>> loadConfig() async {
  final configFile = File(configFileName);
  final jsonString = await configFile.readAsString();
  final dynamic settings = jsonDecode(jsonString);

  String? dir;
  if (settings['webDirectory'] != null &&
      (dir = await checkDir(settings['webDirectory'])) == null) {
    return Result<bool>.error('web directory not found');
  }
  webdir = dir;
  dir = settings['databaseDirectory'];
  if (dir == null) {
    return Result<bool>.error('no database directory');
  }
  databaseDirectory = dir;
  var jwt = settings['JWTSecret'];
  if (jwt == null || jwt.isEmpty) {
    return Result<bool>.error('no JW secrect');
  }
  secretPassphrase = jwt;

  if (settings['serverPort'] is! int) {
    return Result<bool>.error('invalid port');
  }
  serverPort = settings['serverPort'];
  serverUrl = settings['serverUrl'];
  return Result.value(true);
}
