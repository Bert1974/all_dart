import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:main/src/forms/properties_edit.dart';
import 'package:main/src/authentication.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum _TypeTab { local, network }

class _LoginPageState extends State<LoginPage> {
  int disabled = 0;
  _TypeTab _type = _TypeTab.network;

  static final List<R> _layout = [
    R([
      C({'xs': 6}, offsets: {'xs': 3}, data: 'type'),
      C({'xs': 12}, data: Cell(Var2.text, 'Login', varName: 'name')),
      C({'xs': 12}, data: Cell(Var2.text, 'Password', varName: 'password')),
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
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                      child: ListTile(
                                                    title: const Text('Local'),
                                                    leading: Radio<_TypeTab>(
                                                      value: _TypeTab.local,
                                                      groupValue: _type,
                                                      onChanged:
                                                          (_TypeTab? value) {
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
                                                    leading: Radio<_TypeTab>(
                                                      value: _TypeTab.network,
                                                      groupValue: _type,
                                                      onChanged:
                                                          (_TypeTab? value) {
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
      switch (_type) {
        case _TypeTab.local:
          break;
        case _TypeTab.network:
          {
            setState(() {
              disabled++;
            });
            var auth = AuthenticationHandler.of(this.context);
            await auth.login(this.context, _login);
            setState(() {
              disabled--;
            });
          }
          break;
      }
    }
  }
}
