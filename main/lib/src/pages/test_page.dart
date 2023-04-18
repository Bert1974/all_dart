import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';

class TestPage extends AppPageStatefulWidget<TestPage> {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();

  @override
  Widget title(BuildContext context) =>
      Text(AppLocalizations.of(context)!.appTitle);
}

class _TestPageState extends State<TestPage> {
  List<Server> servers = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  _refresh() {
    DBHandler db = DBHandler.of(context);
    var auth = AuthenticationHandler.of(context);

    db.getServers(auth.value.user).then((res) {
      if (res.result != null) {
        setState(() => servers = res.result!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Servers',
              ),
              const Divider(),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(children: const []),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 51,
                            child: ElevatedButton(
                              onPressed: () async {
                                showDialogPopup(
                                    context: context,
                                    title: 'New server',
                                    child: NewServerDialog(context: context));
                              },
                              child: // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  Row(
                                children: const [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Voeg toe",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          )
                        ]),
                  ]),
              const SizedBox(height: 10),
            ]),
      ))
    ]);
  }
}
