import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:data/data.dart';
import 'package:server/server.dart' as server;

const int _totalThtreads = 4;

void main(List<String> arguments) async {
  var r = await server.loadConfig();
  if (r.result ?? false) {
    var completer = Completer();
    //final receivePort = ReceivePort();
    print('openstore');
    Database connection;
    final Result<Database> openresult =
        Database.openStore(server.databaseDirectory);
    if (openresult.result == null) {
      print('failed opening store:${openresult.error!}');
      exit(1);
    }
    connection = openresult.result!;
    await connection.open();
    var reference = connection.getReference();

    if (true) {
//    connection.seed();
//    var u = await connection.login("Bert", "123");
    }

    print('starting $_totalThtreads isolates.');

    for (var i = 0; i < _totalThtreads; i++) {
      unawaited(Isolate.spawn(server.startServer, [reference]));
    }
    var quitSignalListner = ProcessSignal.sigint.watch().listen((signal) {
      completer.complete(null);
    });

    await completer.future;

    quitSignalListner.cancel();

    print('sever exit.');

    exit(0);
  } else {
    print('configuration invalid:${r.error}');
  }
}
