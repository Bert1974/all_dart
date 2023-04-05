import 'dart:typed_data';

import 'package:alfred/alfred.dart';
import 'package:data/data.dart';

response(String message, dynamic data, bool success) {
  return <String, dynamic>{
    'data': data,
    'message': message,
    'success': success
  };
}

responeError(String message) => response(message, null, false);
responseException(e) => response(e.toString(), null, false);
responseData(dynamic data) => response("Ok", data, true);

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
  app.all('/login', (req, res) async {
    try {
      final body = (await req.body) as Map<String, dynamic>;
      print(body);
      User? user = await connection.login(body['name'], body['password']);
      print(user != null ? 'found' : 'not found');
      if (user != null) {
        return responseData(<String, dynamic>{'token': '123', 'user': user});
      }
      return responeError("Geen toegang");
    } catch (e) {
      print(e);
      return responseException(e);
    }
  });
  app.all('/example', (req, res) => 'Hello world');

  await app.listen(2222, '127.0.0.1');
}
