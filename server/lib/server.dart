import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:alfred/alfred.dart';
// ignore: implementation_imports
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:data/data.dart';
import 'server_funcs.dart';
import 'package:server/src/localization/servermessages.i18n.dart';

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
        Result<User> user = await getUser(connection, req);
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

void startServer(data) async {
  if ((await loadConfig()).result ?? false) {
    //SendPort sendPort = data[0];
    ByteData reference = data[0];

    Result<Database> openResult = Database.openStore(databaseDirectory);
    connection = openResult.result!;
    connection.setReference(reference);

    final app = Alfred(
        onNotFound: webdir == null
            ? null
            : (req, res) {
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
    if (webdir != null) {
      app.get('*', (req, res) {
        return Directory(webdir!);
      });
    }
    await app.listen(serverPort, serverUrl);
  } else {
    print('configuration invalid');
  }
}
