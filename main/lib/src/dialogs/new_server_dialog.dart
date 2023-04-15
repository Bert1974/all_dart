import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';

class NewServerDialog extends StatefulWidget {
  final BuildContext context;
  const NewServerDialog({super.key, required this.context});

  @override
  State<NewServerDialog> createState() => _NewServerDialogState();
}

class _NewServerDialogState extends State<NewServerDialog> {
  final Map<String, dynamic> _server = Server().toJson();
  bool isDisbled = false;

  List<R> _layout(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    return [
      R([
        C({'xs': 12},
            data: Cell(Var2.text, 'name', varName: 'name')..required = true),
        C({'xs': 12},
            data: Cell(Var2.text, 'server', varName: 'server')
              ..required = true),
      ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: const Key("form1"),
        child: Builder(
            builder: (innerContext2) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PropertiesEdit(
                        /*  variables: [
                                              Variable("Login", Var2.text),
                                              Variable(
                                                  "Password", Var2.password),
                                            ],*/
                        layout: _layout(context),
                        target: _server,
                        disabled: isDisbled,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (cell, value) {
                          setState(() {
                            cell!.setValue(_server, value);
                          });
                        },
                        onSubmit: (cell, value) async {},
                        onClicked: (cell) async {}),
                    const SizedBox(
                      height: 12.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: null,
                      child: const Text(
                        'Opslaan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                      ),
                    ),
                  ],
                )));
  }
}
