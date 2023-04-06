import 'dart:typed_data';

import 'package:alfred/alfred.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:data/data.dart';

const secretPassphrase = '123secretjwt';

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
responseError(String message) => response(message, null, false);
responseException(e) {
  if (e is ServerException) {
    return response(e.message, null, false);
  }
  return response(e.toString(), null, false);
}

responseData(dynamic data) => response("Ok", data, true);

Future<User> _getUser(Database connection, HttpRequest req) async {
  var header = req.headers.value('Authorization');
  if (header?.startsWith('Bearer ') ?? false) {
    var token = header!.substring(7);
    try {
      // Verify a token
      final jwt = JWT.verify(token, SecretKey(secretPassphrase));
      var userName = jwt.payload['id'];
      var user = await connection.checkToken(userName, token);
      if (user != null) {
        return user;
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

void startServer(data) async {
  final app = Alfred();
  //SendPort sendPort = data[0];
  ByteData reference = data[0];

  // final connection = Connection.forServer();
//  final userBox = connection.box<User>();

  final Database connection = Database.openStore();
  connection.setReference(reference);

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
      User user = await _getUser(connection, req);
      final body = (await req.body) as Map<String, dynamic>;
      await connection.saveUserSettings(user, body['type'], body['data']);
      return responseOk();
    } catch (e) {
      print(e);
      return responseException(e);
    }
  });
  app.post('/currentuser', (req, res) async {
    try {
      User user = await _getUser(connection, req);
      return responseData(<String, dynamic>{'user': user});
    } catch (e) {
      print(e);
      return responseException(e);
    }
  });
  app.post('/login', (req, res) async {
    try {
      final body = (await req.body) as Map<String, dynamic>;
      User? user = await connection.login(body['name'], body['password']);
      if (user != null) {
        // Create a json web token
// Pass the payload to be sent in the form of a map
        final jwt = JWT(
          // Payload
          {
            'id': user.name,
          },

          issuer: 'https://git.bertbruggeman.nl',
        );

        // Sign it (default with HS256 algorithm)
        var token = jwt.sign(SecretKey(secretPassphrase),
            expiresIn: Duration(hours: 2));
        return responseData(<String, dynamic>{'token': token, 'user': user});
      }
      return responseError("Geen toegang");
    } catch (e) {
      print(e);
      return responseException(e);
    }
  });
  app.all('/example', (req, res) => 'Hello world');

  await app.listen(2222, '127.0.0.1');
}
