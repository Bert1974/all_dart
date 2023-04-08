import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main/src/widgets/property_edit.dart';

import 'row_col_layout.dart';

class PropertiesEdit extends StatefulWidget {
  final List<R>? layout;
  final Widget? Function(dynamic name)? lookupfunction;
  final bool disabled;
  final FutureOr<void> Function(Cell? v, dynamic value)? onChanged;
  final FutureOr<void> Function(Cell? v, dynamic value)? onSubmit;
  final FutureOr<void> Function(Cell? v)? onClicked;
  final dynamic target;

  const PropertiesEdit(
      {super.key,
      required this.target,
      this.disabled = false,
      this.layout,
      this.lookupfunction,
      this.onChanged,
      this.onSubmit,
      this.onClicked});

  @override
  State<PropertiesEdit> createState() => _PropertiesEditState();
}

class _PropertiesEditState extends State<PropertiesEdit> {
  @override
  Widget build(BuildContext context) {
    if (widget.layout != null) {
      return RowColLayout(
          layout: widget.layout!,
          lookupfunction: _lookupfunction,
          useScreenSize: false);
    }
    throw Exception('unimplemented');
    // return Column(
    //   children: variables.map<Widget>((p) => createPropertyEdit(p)).toList());
  }

  String? Function(dynamic)? _getValidator(Cell cell) {
    switch (cell.type!) {
      case Var2.text:
      case Var2.password:
      case Var2.ip:
      case Var2.number:
        return (value_) =>
            value_ != null && value_.length > 0 ? null : 'required';

      case Var2.checkbox:
      case Var2.button:
        return null;
    }
  }

  Widget? _lookupfunction(dynamic value) {
    if (value is Cell) {
      return PropertyEdit(
          cell: value,
          initialValue: value.getValue(widget.target),
          onClicked: widget.onClicked,
          onFieldSubmitted: !widget.disabled && widget.onSubmit != null
              ? (value_) => widget.onSubmit?.call(value, value_)
              : null,
          onChanged: widget.onChanged != null
              ? (value_) => widget.onChanged?.call(value, value_)
              : null,
          validator: _getValidator(value));
    }
    return widget.lookupfunction?.call(value);
  }
}
