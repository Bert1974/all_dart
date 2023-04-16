import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets.dart';

class PropertiesEdit extends StatefulWidget {
  final List<R>? layout;
  final Widget? Function(dynamic name)? lookupfunction;
  final bool disabled;
  final FutureOr<void> Function(Cell? v, dynamic value)? onChanged;
  final FutureOr<void> Function(Cell? v, dynamic value)? onSubmit;
  final FutureOr<void> Function(Cell? v)? onClicked;
  final dynamic target;
  final AutovalidateMode autovalidateMode;

  const PropertiesEdit(
      {super.key,
      required this.target,
      this.disabled = false,
      this.layout,
      this.lookupfunction,
      this.onChanged,
      this.onSubmit,
      this.onClicked,
      this.autovalidateMode = AutovalidateMode.disabled});

  @override
  State<PropertiesEdit> createState() => _PropertiesEditState();
}

class _PropertiesEditState extends State<PropertiesEdit> {
  @override
  Widget build(BuildContext context) {
    if (widget.layout != null) {
      return RowColLayout(
          layout: widget.layout!, lookupfunction: _lookupfunction);
    }
    throw Exception('unimplemented');
    // return Column(
    //   children: variables.map<Widget>((p) => createPropertyEdit(p)).toList());
  }

  String? Function(dynamic)? add(
      String? Function(dynamic)? result, String? Function(dynamic) newfunc) {
    if (result != null) {
      return (value) => result(value) ?? newfunc(value);
    } else {
      return newfunc;
    }
  }

  String? Function(dynamic)? _getValidator(BuildContext context, Cell cell) {
    String? Function(dynamic)? result;
    final translations = AppLocalizations.of(context)!;

    if (cell.required) {
      result = add(
          result,
          (value_) => value_ != null && value_.toString().isNotEmpty
              ? null
              : translations.validation_required(cell.name ?? cell.varName!));
    }
    return result;
  }

  Widget? _lookupfunction(BuildContext context, dynamic value) {
    if (value is Cell) {
      return PropertyEdit(
          cell: value,
          initialValue: value.getValue(widget.target),
          autovalidateMode: widget.autovalidateMode,
          enabled: !widget.disabled,
          onClicked: widget.onClicked,
          onSubmitted: !widget.disabled && widget.onSubmit != null
              ? (value_) => widget.onSubmit?.call(value, value_)
              : null,
          onSaved: widget.onChanged != null
              ? (value_) => widget.onChanged?.call(value, value_)
              : null,
          validator: _getValidator(context, value));
    }
    return widget.lookupfunction?.call(value);
  }
}
