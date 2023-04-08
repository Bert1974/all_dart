import 'dart:async';

import 'package:flutter/material.dart';
import 'package:main/src/widgets.dart';

class PropertyEdit extends FormField<dynamic> {
  final Cell cell;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
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
    this.onChanged,
    this.onFieldSubmitted,
    this.onClicked,
    this.helpText,
  });

  @override
  FormFieldState<dynamic> createState() => _PropertyEditImplState();

  static Widget _doBuild(FormFieldState<dynamic> state_) {
    var state = state_ as _PropertyEditImplState;
    var widget = state.widget as PropertyEdit;

    switch (widget.cell.type!) {
      case Var2.text:
      case Var2.password:
      case Var2.ip:
      case Var2.number:
        return Column(children: [
          Row(children: [
            Expanded(
                child: TextField(
              enableInteractiveSelection: widget.onFieldSubmitted != null,
              enabled: widget.onFieldSubmitted != null,
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
                filled: widget.onFieldSubmitted != null,
                //  fillColor: Colors.grey.shade100,
                labelText: widget.cell.name,
                hintText: widget.cell.name,
                prefixText: null,
              ),
              obscureText: widget.cell.type == Var2.password,
              //      autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: state._controller,
              //     initialValue: widget.initialValue ?? '!',
              onSubmitted: (widget.onFieldSubmitted == null)
                  ? null
                  : (value) {
                      widget.onFieldSubmitted?.call(value);
                    },
              onChanged: (value) {
                state.didChange(state._controller.text);
                //  widget.onChanged?.call(value);
              },
              //     validator: null, // (v) => v == null || v == "" ? "needed" : null,
              keyboardType: /* TextInputType.phone : */ null,
              inputFormatters: // FilteringTextInputFormatter.digitsOnly,
                  null,
              maxLength: null,
            ))
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
          onPressed: () async {
            await widget.onClicked?.call(widget.cell);
          },
          child: Text(widget.cell.name!),
        );
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
      case Var2.password:
      case Var2.ip:
      case Var2.number:
        _controller.value = _controller.value.copyWith(text: super.value ?? '');
        break;
      default:
        break;
    }
    return super.build(context);
  }

  @override
  void reset() {
    super.reset();
    _controller.value = _controller.value.copyWith(text: super.value ?? '');
    _widget.onChanged?.call(value);
  }

  @override
  void didChange(dynamic value) {
    super.didChange(value);
    _widget.onChanged?.call(value);
  }

  @protected
  @override
  // ignore: use_setters_to_change_properties, (API predates enforcing the lint)
  void setValue(dynamic value) {
    super.setValue(value);
    _controller.value = _controller.value.copyWith(text: super.value ?? '');
  }

  @mustCallSuper
  @protected
  @override
  void didUpdateWidget(covariant dynamic oldWidget) {
    super.didUpdateWidget(oldWidget);
    super.setValue(_widget.initialValue);
  }
}
