import 'dart:io';
import 'dart:typed_data';

// ignore: implementation_imports
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:data/data.dart';
import 'server_funcs.dart';

void startServer(data) async {
  if ((await loadConfig()).result ?? false) {
    //SendPort sendPort = data[0];
    ByteData reference = data[0];

    Result<Database> openResult = Database.openStore(databaseDirectory);
    connection = openResult.result!;
    connection.setReference(reference);
/*
final SimpleServerSocket server = await SimpleServerSocket.bind();

server.on<SimpleSocket>('connection', (SimpleSocket client) {
  // or: client.sendMessage('hello', 'Hi, client.');
  client.sendSignal('hello');

  client.on<void>('bye', (_) => server.destroy());
});
*/
  } else {
    print('configuration invalid');
  }
}
