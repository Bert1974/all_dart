import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/src/settings/authentication.dart';
import 'package:main/src/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        servers = res.result!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Text(
      "HELLO!",
      //     style: Theme.of(context).textTheme.body1,
    );
  }
}
