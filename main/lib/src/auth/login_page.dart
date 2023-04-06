import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:main/src/widgets/properties_edit.dart';
import 'package:main/src/settings/authentication.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int disabled = 0;
  DatabaseTypes _type = Database.openStore() != null
      ? DatabaseTypes.local
      : DatabaseTypes.network;

  static final List<R> _layout = [
    R([
      C({'xs': 6, 'md': 12}, offsets: {'xs': 3, 'md': 0}, data: 'type'),
      C({'xs': 12}, data: Cell(Var2.text, 'Login', varName: 'name')),
      C({'xs': 12}, data: Cell(Var2.password, 'Password', varName: 'password')),
      C({'xs': 6}, offsets: {'xs': 3}, data: Cell(Var2.button, "Connect")),
    ])
  ];

  var _login = Login().toJson();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        /*  title: Text(
          title,
          //       style: Theme.of(context).textTheme.title,
        ),
        width:
        actions: [],
        content:*/
        child: ScaffoldMessenger(
            child: Scaffold(
                body: Builder(
                    builder: (innerContext) => Column(children: [
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
                                            if (n == "type") {
                                              if (Database.openStore() ==
                                                  null) {
                                                return null;
                                              }
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                      child: ListTile(
                                                    title: const Text('Local'),
                                                    leading:
                                                        Radio<DatabaseTypes>(
                                                      value:
                                                          DatabaseTypes.local,
                                                      groupValue: _type,
                                                      onChanged: (DatabaseTypes?
                                                          value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            _type = value;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  )),
                                                  Flexible(
                                                      child: ListTile(
                                                    title:
                                                        const Text('Network'),
                                                    leading:
                                                        Radio<DatabaseTypes>(
                                                      value:
                                                          DatabaseTypes.network,
                                                      groupValue: _type,
                                                      onChanged: (DatabaseTypes?
                                                          value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            _type = value;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  )),
                                                ],
                                              );
                                            }
                                            /*  return _login!.lookup((f) {
                                                    setState(() {
                                                      f();
                                                    });
                                                  }, n);*/
                                          }
                                          return null;
                                        }))),
                            const Text(
                              "HELLO!",
                              //     style: Theme.of(context).textTheme.body1,
                            )
                          ]
                        ])))));
  }

  _submit(BuildContext context) async {
    var cipform = Form.of(context);

    if (cipform.validate()) {
      setState(() {
        disabled++;
      });
      DBHandler db = DBHandler.of(context);
      var auth = AuthenticationHandler.of(this.context);

      await db.open(_type);
      // ignore: use_build_context_synchronously
      await auth.login(this.context, Login.fromJson(_login));

      setState(() {
        disabled--;
      });
    }
  }
}
