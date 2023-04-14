import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main/main.dart';

class PropertyEdit extends FormField<dynamic> {
  final Cell cell;
  final ValueChanged<String>? onSubmitted;
  final FutureOr<void> Function(Cell)? onClicked;
  final String? helpText;

  const PropertyEdit({
    super.key,
    super.builder = PropertyEdit._doBuild,
    required this.cell,
    super.initialValue,
    super.autovalidateMode,
    super.validator,
    super.onSaved,
    this.onSubmitted,
    this.onClicked,
    super.enabled,
    this.helpText,
  });

  @override
  FormFieldState<dynamic> createState() => _PropertyEditImplState();

  static Widget _doBuild(FormFieldState<dynamic> state_) {
    var state = state_ as _PropertyEditImplState;
    var widget = state.widget as PropertyEdit;

    switch (widget.cell.type!) {
      case Var2.text:
      case Var2.email:
      case Var2.phone:
      case Var2.file:
      case Var2.directory:
      case Var2.password:
      case Var2.url:
      case Var2.number:
        return Column(children: [
          Row(children: [
            Expanded(
                child: TextField(
              enableInteractiveSelection: widget.enabled,
              enabled: widget.enabled,
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
                filled: widget.enabled,
                //  fillColor: Colors.grey.shade100,
                labelText: widget.cell.name,
                hintText: widget.cell.name,
                prefixText: null,
              ),
              obscureText: widget.cell.type == Var2.password,
              controller: state._controller,
              onSubmitted: (widget.onSubmitted == null)
                  ? null
                  : (value) {
                      widget.onSubmitted?.call(value);
                    },
              onChanged: (value) {
                state._newValue(value);
              },
              //     validator: null, // (v) => v == null || v == "" ? "needed" : null,
              keyboardType: widget.cell.type == Var2.number
                  ? const TextInputType.numberWithOptions(
                      decimal: false, signed: false)
                  : widget.cell.type == Var2.url
                      ? TextInputType.url
                      : widget.cell.type == Var2.email
                          ? TextInputType.emailAddress
                          : widget.cell.type == Var2.phone
                              ? TextInputType.phone
                              : widget.cell.type == Var2.datetime
                                  ? TextInputType.datetime
                                  : null,
              inputFormatters: [
                if (widget.cell.type == Var2.number)
                  FilteringTextInputFormatter.digitsOnly
              ],
              maxLength: null,
            )),
            if (widget.cell.type == Var2.directory) const SizedBox(width: 20),
            if (widget.cell.type == Var2.file) const SizedBox(width: 20),
          ]),
          if (state.hasError)
            Text(
              state.errorText!,
              style: const TextStyle(color: Colors.red),
            )
        ]);
      case Var2.checkbox:
        return const Text("checkbox");
      case Var2.button:
        return TextButton(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: widget.enabled
              ? () async {
                  await widget.onClicked?.call(widget.cell);
                }
              : null,
          child: Text(widget.cell.name!),
        );
      case Var2.datetime:
        throw UnsupportedError('Not implemented');
    }
  }
}

class _PropertyEditImplState extends FormFieldState<dynamic> {
  final TextEditingController _controller = TextEditingController();

  PropertyEdit get _widget => widget as PropertyEdit;

  _PropertyEditImplState() {
    //
  }

  @override
  void initState() {
    super.initState();
    _controller.value = TextEditingValue(text: super.value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    switch (_widget.cell.type!) {
      case Var2.text:
      case Var2.email:
      case Var2.phone:
      case Var2.password:
      case Var2.url:
      case Var2.number:
      case Var2.file:
      case Var2.directory:
        _controller.value = _controller.value.copyWith(text: super.value ?? '');
        break;
      case Var2.datetime:
        throw UnsupportedError('Not implemented');
      case Var2.checkbox:
      case Var2.button:
        break;
    }
    return super.build(context);
  }

  @override
  void reset() {
    super.reset();
    _controller.value = _controller.value.copyWith(text: super.value ?? '');
    // _widget.onSaved?.call(value);
  }

  @mustCallSuper
  @protected
  @override
  void didUpdateWidget(covariant dynamic oldWidget) {
    super.didUpdateWidget(oldWidget);
    super.setValue(_widget.initialValue);
    _controller.value = _controller.value.copyWith(text: super.value ?? '');
  }

  void _newValue(String value) {
    didChange(_controller.text);
    save();
  }
}
