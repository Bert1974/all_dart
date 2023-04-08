import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:main/src/settings/authentication.dart';
import 'package:main/src/widgets.dart';
import 'package:path/path.dart' as p;

class LoginPage extends AppPageStatefulWidget<LoginPage> {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

  @override
  Widget get title => const Text("Login");
}

class _LoginPageState extends State<LoginPage> {
  int disabled = 0;

  var _login = Login().toJson();
  var _storage = <String, dynamic>{};

  List<R> get _layout => [
        R([
          C({'xl': 4, 'md': 12},
              offsets: {'xl': 4, 'md': 0}, data: _createTypeWidgets),
          if (_storage['type'] == DatabaseTypes.local.index) ...[
            C({'xs': 12},
                data: Cell(Var2.text, 'Database',
                    getter: (value) => _storage['database'],
                    setter: (target, value) => _storage['database'] = value)),
          ],
          if (_storage['type'] == DatabaseTypes.network.index) ...[
            C({'xs': 12},
                data: Cell(Var2.text, 'Server',
                    getter: (value) => _storage['server'],
                    setter: (target, value) => _storage['server'] = value)),
          ],
          C({'xs': 12}, data: Cell(Var2.text, 'Login', varName: 'name')),
          C({'xs': 12},
              data: Cell(Var2.password, 'Password', varName: 'password')),
          C({'xs': 6}, offsets: {'xs': 3}, data: Cell(Var2.button, "Connect")),
        ])
      ];

  Widget? _createTypeWidgets() {
    if (!Database.checkStore) {
      return null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
            child: ListTile(
          title: const Text('Local'),
          leading: Radio<int>(
              value: DatabaseTypes.local.index,
              groupValue: _storage['type'],
              onChanged: (int? value) => _setType(value)),
        )),
        Flexible(
            child: ListTile(
          title: const Text('Network'),
          leading: Radio<int>(
              value: DatabaseTypes.network.index,
              groupValue: _storage['type'],
              onChanged: (int? value) => _setType(value)),
        )),
      ],
    );
  }

  _setType(int? value) {
    if (value != null && _storage['type'] != value) {
      setState(() {
        if (value == DatabaseTypes.local.index) {
          _storage = {
            'type': value,
            'database': p.join(documentsDirectory, 'data.mdb')
          };
        } else if (value == DatabaseTypes.network.index) {
          _storage = {'type': value, 'server': 'http://127.0.0.1:2222'};
        }
      });
    }
  }

  @override
  void initState() {
    _setType(Database.checkStore
        ? DatabaseTypes.local.index
        : DatabaseTypes.network.index);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        //  title: const Text('Login'),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Row(children: [Text("Login")]),
              if (disabled == 0) ...[
                Form(
                    key: const Key("form1"),
                    child: Builder(
                        builder: (innerContext2) => PropertiesEdit(
                            /*  variables: [
                                              Variable("Login", Var2.text),
                                              Variable(
                                                  "Password", Var2.password),
                                            ],*/
                            layout: _layout,
                            target: _login,
                            disabled: disabled > 0,
                            onChanged: (cell, value) {
                              setState(() {
                                cell!.setValue(_login, value);
                              });
                            },
                            onSubmit: (cell, value) async {
                              await _submit(innerContext2);
                            },
                            onClicked: (cell) async {
                              await _submit(innerContext2);
                            },
                            lookupfunction: (n) {
                              if (n is String) {
                                if (n == "type") {}
                                /*  return _login!.lookup((f) {
                                                    setState(() {
                                                      f();
                                                    });
                                                  }, n);*/
                              }
                              return null;
                            }))),
              ]
            ])));
  }

  _submit(BuildContext context) async {
    var cipform = Form.of(context);

    if (cipform.validate()) {
      setState(() {
        disabled++;
      });
      DBHandler db = DBHandler.of(context);
      var auth = AuthenticationHandler.of(this.context);

      var dbtype = DatabaseTypes.values[_storage['type'] as int];

      await db.open(dbtype, _storage);

      // ignore: use_build_context_synchronously
      await auth.login(this.context, Login.fromJson(_login));

      setState(() {
        disabled--;
      });
    }
  }
}
