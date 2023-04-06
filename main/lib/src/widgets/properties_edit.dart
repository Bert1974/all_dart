import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:main/src/widgets/property_edit.dart';

import 'row_col_layout.dart';

class PropertiesEdit extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (layout != null) {
      return RowColLayout(
          layout: layout!,
          lookupfunction: _lookupfunction,
          useScreenSize: false);
    }
    throw Exception('unimplemented');
    // return Column(
    //   children: variables.map<Widget>((p) => createPropertyEdit(p)).toList());
  }

  Widget? _lookupfunction(dynamic value) {
    if (value is Cell) {
      return PropertyEdit(
          cell: value,
          initalValue: value.getValue(target),
          onClicked: onClicked,
          onSubmit: !disabled ? onSubmit : null,
          onChanged: onChanged);
    }
    return lookupfunction?.call(value);
  }

  /*Widget createPropertyEdit(Cell cell) {
    return PropertyEdit(
        cell: cell,
        initalValue: (target is Map<String, dynamic> && cell.varName != null)
            ? (target as Map<String, dynamic>)[cell.varName!]
            : cell.getValue(target),
        onChanged: (cell, v) {
          if (target is Map<String, dynamic> && cell.varName != null) {
            (target as Map<String, dynamic>)[cell.varName!] = v;
          } else if (cell.varName == null) {
            cell.setValue(target, v);
          }
          onChanged?.call(cell);
        },
        onSubmit: (cell, v) {
          if (target is Map<String, dynamic> && cell.varName != null) {
            (target as Map<String, dynamic>)[cell.varName!] = v;
          } else {
            cell.setValue(target, v);
          }
          onSubmit?.call(cell);
        });
  }*/
}
