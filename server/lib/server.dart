import 'dart:typed_data';

import 'package:alfred/alfred.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:data/data.dart';
import 'package:server/src/localization/servermessages.i18n.dart';

const secretPassphrase = '123secretjwt';
const String databaseDirectory = "database";
const serverPort = 2222;
const serverUrl = "192.168.178.15";

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

void startServer(data) async {
  //SendPort sendPort = data[0];
  ByteData reference = data[0];

  connection = Database.openStore(databaseDirectory)!;
  connection.setReference(reference);

  final app = Alfred();

  app.all('*', cors(/*origin: '127.0.0.1:2222')*/));

  /* app.all('/api/call/database/test', (req, res) async {
    try {
      final body = (await req.body) as Map<String, dynamic>;
      var settings =
          DatabaseSettingsExtension.fromJson(body['type'], body['database']);

      if (settings != null) {
        if (await connection.testdatabase(settings)) {
          return {'data': {}, 'message': 'ok', 'success': true};
        }
        return {'data': {}, 'message': 'can\'t connect', 'success': false};
      } else {
        return {'data': {}, 'message': 'error', 'success': false};
      }
    } catch (e) {
      //catched
    }
  });*/
  app.post('/user/setting', (req, res) async {
    try {
      var connection = getConnection(req);
      Result<User> user = await _getUser(connection, req);
      if (user.result != null) {
        final body = (await req.body) as Map<String, dynamic>;
        await connection.saveUserSettings(
            user.result!, body['type'], body['data']);
        return responseOk();
      }
      return responseError(user.error);
    } catch (e) {
      print(e);
      return responseException(e);
    }
  });
  app.post('/currentuser', (req, res) async {
    try {
      var connection = getConnection(req);
      Result<User> user = await _getUser(connection, req);
      if (user.result != null) {
        return responseData(<String, dynamic>{'user': user.result});
      }
      return responseError(user.error);
    } catch (e) {
      print(e);
      return responseException(e);
    }
  });
  app.post('/login', (req, res) async {
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
  app.all('/example', (req, res) => 'Hello world');

  await app.listen(serverPort, serverUrl);
}
