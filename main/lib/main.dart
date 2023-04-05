import 'package:flutter/material.dart';

export 'main.stub.dart'
    if (dart.library.io) 'main.desktop.dart'
    if (dart.library.js) 'main.web.dart';

const String baseUrl = 'http://127.0.0.1:2222/';

class PageContext {
  BuildContext? context;
}

class R {
  final List<C> columns;
  const R(this.columns);
}

class C {
  final Map<String, int>? sizes;
  final Map<String, int>? offsets;
  final dynamic data;
  C(this.sizes, {this.data, this.offsets}) {
    if (sizes == null && offsets == null) {
      throw Exception('empty column');
    }
  }
}

class Cell {
  final Var2? type;
  final String? name;
  final String? varName;
  final dynamic Function(dynamic)? getter;
  final dynamic Function(dynamic, dynamic)? setter;

  Cell(this.type, this.name, {this.varName, this.getter, this.setter});
  getValue(target) {
    if (target is Map<String, dynamic>) {
      return target[varName];
    } else if (getter != null) {
      switch (type) {
        case Var2.ip:
        case Var2.text:
        case Var2.password:
          return getter!(target);

        case Var2.number:
          return getter!(target)?.toString();

        default:
          throw UnsupportedError('Not implemented');
      }
    }
    return null;
  }

  setValue(target, value) {
    if (target is Map<String, dynamic>) {
      target[varName!] = value;
    } else {
      if (setter != null) {
        switch (type) {
          case Var2.ip:
          case Var2.text:
          case Var2.password:
            setter!(target, value);
            break;
          case Var2.number:
            setter!(target, value != null ? int.parse(value as String) : null);
            break;

          default:
            throw UnsupportedError('Not implemented');
        }
      }
    }
  }
}

enum Var2 { text, number, checkbox, password, ip, button }
