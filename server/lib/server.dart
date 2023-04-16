import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:alfred/alfred.dart';
// ignore: implementation_imports
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:data/data.dart';
import 'package:server/src/localization/servermessages.i18n.dart';

const configFileName = 'config.json';

late final String secretPassphrase;
late final String databaseDirectory;
late final int serverPort;
late final  String serverUrl;
late final String webdir;

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

Future<Result<User>> _getUser(Database connection, HttpRequest req) async {
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

extension AlfredExtension on Alfred {
  HttpRoute auth(
    String path,
    FutureOr Function(
            HttpRequest req, HttpResponse res, Database connection, User user)
        callback, {
    List<FutureOr Function(HttpRequest req, HttpResponse res)> middleware =
        const [],
  }) {
    return post(path, (req, res) async {
      try {
        var connection = getConnection(req);
        Result<User> user = await _getUser(connection, req);
        if (user.result != null) {
          return callback(req, res, connection, user.result!);
        }
        return responseError(user.error);
      } catch (e) {
        print(e);
        return responseException(e);
      }
    }, middleware: middleware);
  }
}

Future<String?> checkDir(String? path) async {
  if (path != null && path.isNotEmpty) {
    return await Directory(path).exists() ? path : null;
  }
  return null;
}

Future<bool> loadConfig() async {
  final configFile = File(configFileName);
  final jsonString = await configFile.readAsString();
  final dynamic settings = jsonDecode(jsonString);

  var dir = await checkDir(settings['webDirectory']);
  if (dir == null) {
    return false;
  }
  webdir = dir;
  dir = await checkDir(settings['databaseDirectory']);
  if (dir == null) {
    return false;
  }
  databaseDirectory = dir;
  var jwt = settings['JWTSecret'];
  if (jwt == null || jwt.isEmpty) {
    return false;
  }
  secretPassphrase = jwt;

  if (settings['serverPort'] is! int) {
    return false;
  }
  serverPort = settings['serverPort'];
  serverUrl = settings['serverUrl'];
  return true;
}

void startServer(data) async {
  if (await loadConfig()) {
    //SendPort sendPort = data[0];
    ByteData reference = data[0];

    connection = Database.openStore(databaseDirectory)!;
    connection.setReference(reference);

    final app = Alfred(onNotFound: (req, res) {
      return File('${webdir}index.html');
    });

    app.all('*', cors(/*origin: '127.0.0.1:2222')*/));

    app.auth('/api/user/setting', (req, res, connection, user) async {
      final body = (await req.body) as Map<String, dynamic>;
      await connection.saveUserSettings(user, body['type'], body['data']);
      return responseOk();
    });
    app.auth('/api/servers', (req, res, connection, user) async {
      return responseResult<List<Server>>(
          await connection.getServers(user),
          (List<Server> data) =>
              data.map((s) => s.toJson() as dynamic).toList());
    });
    app.auth('/api/save_server', (req, res, connection, user) async {
      final body = (await req.body) as Map<String, dynamic>;
      return responseResult<bool>(
          await connection.saveServer(user, Server.fromJson(body)),
          (bool data) => data);
    });
    app.auth('/api/currentuser', (req, res, connection, user) async {
      return responseData(<String, dynamic>{'user': user});
    });
    app.post('/api/login', (req, res) async {
      try {
        var connection = getConnection(req);
        final body = (await req.body) as Map<String, dynamic>;
        Result<User> user =
            await connection.login(body['name'], body['password']);
        if (user.result != null) {
          // Create a json web token
// Pass the payload to be sent in the form of a map
          final jwt = JWT(
            // Payload
            {
              'id': user.result!.name,
            },

            issuer: 'https://git.bertbruggeman.nl',
          );

          // Sign it (default with HS256 algorithm)
          var token = jwt.sign(SecretKey(secretPassphrase),
              expiresIn: Duration(hours: 2));
          return responseData(
              <String, dynamic>{'token': token, 'user': user.result});
        }
        return responseError(user.error);
      } catch (e) {
        print(e);
        return responseException(e);
      }
    });
    // WebSocket chat relay implementation
    app.get('/ws', (req, res) {
      return WebSocketSession(
        onOpen: (ws) {},
        onClose: (ws) {},
        onMessage: (ws, dynamic data) async {},
      );
    });
    app.get('*', (req, res) {
      return Directory(webdir);
    });
    await app.listen(serverPort, serverUrl);
  }
}
