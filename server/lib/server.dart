import 'dart:typed_data';

import 'package:alfred/alfred.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:data/data.dart';

response(String message, dynamic data, bool success) {
  return <String, dynamic>{
    'data': data,
    'message': message,
    'success': success
  };
}

responseError(String message) => response(message, null, false);
responseException(e) => response(e.toString(), null, false);
responseData(dynamic data) => response("Ok", data, true);

Future<User?> _getUser(Database connection, HttpRequest req) async {
  var token = req.headers.value('Authorization');
  print(token);
  return null;
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
      User? user = await _getUser(connection, req);
      final body = (await req.body) as Map<String, dynamic>;
    } catch (e) {
      print(e);
      return responseException(e);
    }
  });
  app.post('/currentuser', (req, res) async {
    try {
      User? user = await _getUser(connection, req);
      final body = (await req.body) as Map<String, dynamic>;
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
        /* final jwt = JWT(

          // Payload
          {
            'id': user.id,

            'server': {
              'id': '3e4fc296',
              'loc': 'euw-2',
            }

          },

          issuer: 'https://git/bertbruggeman.nl',

        );

        // Sign it (default with HS256 algorithm)
        var token = jwt.sign(SecretKey('secret passphrase'),expiresIn: Duration(hours: 2));*/
        return responseData(<String, dynamic>{'token': '123', 'user': user});
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
