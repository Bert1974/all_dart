import 'dart:async';

import 'package:flutter/material.dart';
import 'package:main/main.dart';

/*
class PropertyEdit extends StatefulWidget {
  final Cell cell;
  final dynamic initalValue;
  final void Function(Cell, dynamic)? onChanged;
  final void Function(Cell, dynamic)? onSubmit;
  final Function(Cell)? onClicked;

  const PropertyEdit({
    super.key,
    required this.cell,
    this.initalValue,
    this.onChanged,
    this.onSubmit,
    this.onClicked,
  });

  @override
  State<PropertyEdit> createState() => PropertyEditState();
}

class PropertyEditState extends State<PropertyEdit> {
  final String? helpText = "???";


  @override
  Widget build(BuildContext context) {
    return PropertyEditImpl(
        builder: _doBuild,
        cell: widget.cell,
        onChanged: widget.onChanged,
        onSubmit: widget.onSubmit,
        onClicked: widget.onClicked);
  }

  @override
  void initState() {
    super.initState();
  }
}
*/
class PropertyEdit extends FormField<dynamic> {
  final Cell cell;
  final dynamic initalValue;
  final FutureOr<void> Function(Cell, dynamic)? onChanged;
  final FutureOr<void> Function(Cell, dynamic)? onSubmit;
  final FutureOr<void> Function(Cell)? onClicked;
  final String? helpText;

  const PropertyEdit(
      {super.key,
      super.builder = PropertyEdit._doBuild,
      required this.cell,
      this.initalValue,
      this.onChanged,
      this.onSubmit,
      this.onClicked,
      this.helpText});

  @override
  FormFieldState<dynamic> createState() => _PropertyEditImplState();

  static Widget _doBuild(FormFieldState<dynamic> state) {
    var widget = state.widget as PropertyEdit;
    switch (widget.cell.type!) {
      case Var2.text:
      case Var2.password:
      case Var2.ip:
      case Var2.number:
        return Row(children: [
          Expanded(
              // ignore: sort_child_properties_last
              child: TextFormField(
            enableInteractiveSelection: widget.onSubmit != null,
            enabled: widget.onSubmit != null,
            decoration: InputDecoration(
              suffixIcon: widget.helpText != null
                  ? Material(
                      color: Colors.transparent,
                      child: Tooltip(
                        message: widget.helpText,
                        padding: const EdgeInsets.all(10),
                        preferBelow: true,
                        verticalOffset: 20,
                        textAlign: TextAlign.center,
                        child: IconButton(
                          iconSize: 17,
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {},
                        ),
                      ),
                    )
                  : null,
              filled: widget.onSubmit != null,
              fillColor: Colors.grey.shade100,
              labelText: widget.cell.name,
              hintText: widget.cell.name,
              prefixText: null,
            ),
            obscureText: widget.cell.type == Var2.password,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: null,
            initialValue: widget.initalValue,
            onFieldSubmitted: (widget.onSubmit == null)
                ? null
                : (value) async {
                    await widget.onSubmit?.call(widget.cell, value);
                  },
            onChanged: (value) async {
              await widget.onChanged?.call(widget.cell, value);
            },
            validator: null, // (v) => v == null || v == "" ? "needed" : null,
            keyboardType: /* TextInputType.phone : */ null,
            inputFormatters: // FilteringTextInputFormatter.digitsOnly,
                null,
            maxLength: null,
          ))
        ]);
      case Var2.checkbox:
        return const Text("checkbox");
      case Var2.button:
        return TextButton(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () async {
            await widget.onClicked?.call(widget.cell);
          },
          child: Text(widget.cell.name!),
        );
    }
  }
}

class _PropertyEditImplState extends FormFieldState<dynamic> {
  @override
  void initState() {
    //   (widget as PropertyEditImpl).cipformstate?.register(this);
    super.initState();
  }

  @override
  void dispose() {
    //   (widget as PropertyEditImpl).cipformstate?.unregister(this);
    super.dispose();
  }
}
