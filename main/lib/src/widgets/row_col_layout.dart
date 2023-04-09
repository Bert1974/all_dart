import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  bool required = false;

  Cell(this.type, this.name, {this.varName, this.getter, this.setter});
  dynamic getValue(target) {
    dynamic result;
    if (getter != null) {
      result = getter!(target);
    } else if (target is Map<String, dynamic>) {
      result = target[varName];
    } else {
      throw UnsupportedError('Not implemented');
    }
    if (result != null) {
      switch (type) {
        case Var2.url:
        case Var2.text:
        case Var2.email:
        case Var2.phone:
        case Var2.file:
        case Var2.directory:
        case Var2.password:
          break;

        case Var2.number:
          result = result.toString();
          break;

        case Var2.datetime:
        default:
          throw UnsupportedError('Not implemented');
      }
    }
    return result;
  }

  void setValue(dynamic target, dynamic value) {
    switch (type) {
      case Var2.url:
      case Var2.text:
      case Var2.email:
      case Var2.phone:
      case Var2.directory:
      case Var2.file:
      case Var2.password:
        break;
      case Var2.number:
        value = value != null ? int.parse(value as String) : null;
        break;

      case Var2.datetime:
      default:
        throw UnsupportedError('Not implemented');
    }
    if (setter != null) {
      setter!(target, value);
    } else if (target is Map<String, dynamic>) {
      target[varName!] = value;
    } else {
      throw UnsupportedError('Not implemented');
    }
  }
}

enum Var2 {
  text,
  number,
  checkbox,
  password,
  url,
  directory,
  file,
  phone,
  email,
  datetime,
  button
}

Map<String, double?> _csToSize = {
  'xs': null,
  'sm': 576,
  'md': 768,
  'lg': 992,
  'xl': 1200,
  'xxl': 1400,
};

class _Layout {
  int row = 0, col = 0;

  void newRow() {
    row++;
    col = 0;
  }
}

extension _CExtension on C {
  int getOffset(int size, _Layout layout) {
    int? result;
    if (offsets != null) {
      if (offsets!.containsKey('xs')) {
        result = offsets!['xs']!;
      }
      if (offsets!.containsKey('sm')) {
        if (size >= 1 || result == null) {
          result = offsets!['sm']!;
        }
      }
      if (offsets!.containsKey('md')) {
        if (size >= 2 || result == null) {
          result = offsets!['md']!;
        }
      }
      if (offsets!.containsKey('lg')) {
        if (size >= 3 || result == null) {
          result = offsets!['lg']!;
        }
      }
      if (offsets!.containsKey('xl')) {
        if (size >= 4 || result == null) {
          result = offsets!['xl']!;
        }
      }
      if (offsets!.containsKey('xxl')) {
        if (size >= 5 || result == null) {
          result = offsets!['xxl']!;
        }
      }
    }
    return result ?? 0;
  }

  int getSize(int size, _Layout layout) {
    int? result;
    if (sizes != null) {
      if (sizes!.containsKey('xs')) {
        result = sizes!['xs']!;
      }
      if (sizes!.containsKey('sm')) {
        if (size >= 1 || result == null) {
          result = sizes!['sm']!;
        }
      }
      if (sizes!.containsKey('md')) {
        if (size >= 2 || result == null) {
          result = sizes!['md']!;
        }
      }
      if (sizes!.containsKey('lg')) {
        if (size >= 3 || result == null) {
          result = sizes!['lg']!;
        }
      }
      if (sizes!.containsKey('xl')) {
        if (size >= 4 || result == null) {
          result = sizes!['xl']!;
        }
      }
      if (sizes!.containsKey('xxl')) {
        if (size >= 5 || result == null) {
          result = sizes!['xxl']!;
        }
      }
    }
    return result ?? 1;
  }
}

class RowColLayout extends StatelessWidget {
  final List<R> layout;
  final Widget? Function(BuildContext context, dynamic data)? lookupfunction;
  final bool useScreenSize;
  const RowColLayout(
      {super.key,
      required this.layout,
      this.lookupfunction,
      this.useScreenSize = true});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      late double w;
      if (useScreenSize) {
        w = MediaQuery.of(context).size.width;
      } else {
        w = constraints.maxWidth;
      }
      late int size;
      if (w >= _csToSize['xxl']!) {
        size = 5;
      } else if (w >= _csToSize['xl']!) {
        size = 4;
      } else if (w >= _csToSize['lg']!) {
        size = 3;
      } else if (w >= _csToSize['md']!) {
        size = 2;
      } else if (w >= _csToSize['sm']!) {
        size = 1;
      } else {
        size = 0;
      }
      return _doLayoutArray(context, layout, size, constraints, _Layout());
    });
  }

  Widget _doLayoutArray(BuildContext context, List<R> rows, int size,
      BoxConstraints constraints, _Layout layout) {
    List<Widget> result = [];

    for (var row in rows) {
      result.addAll(_doLayoutRow(context, row, size, constraints, layout));
    }
    return Column(children: result);
  }

  List<Widget> _doLayoutRow(BuildContext context, R row, int size,
      BoxConstraints constraints, _Layout layout) {
    List<Row> result = [];
    List<Widget>? currentrow;

    for (var column in row.columns) {
      int colsize = column.getSize(size, layout);
      int coloffset = column.getOffset(size, layout);

      if (currentrow == null || layout.col + colsize > 12) {
        layout.newRow();
        if (currentrow != null) {
          result.add(Row(children: currentrow));
        }
        currentrow = [];
      }
      if (coloffset > 0) {
        layout.col += coloffset;
        double offw = constraints.maxWidth * coloffset / 12;
        currentrow.add(SizedBox(width: offw));
      }
      if (layout.col + colsize > 12) {
        layout.newRow();
        result.add(Row(children: currentrow));
        currentrow = [];
      }
      double realw = constraints.maxWidth * colsize / 12;
      var widget = ((column.data != null)
              ? lookupfunction?.call(context, column.data)
              : null) ??
          _getWidget(context, column, size, realw);

      if (widget != null) {
        if (widget is List<Widget>) {
          currentrow.add(SizedBox(
              width: realw,
              child: Column(mainAxisSize: MainAxisSize.max, children: widget)));
        } else {
          currentrow.add(SizedBox(
              width: realw,
              child:
                  Column(mainAxisSize: MainAxisSize.max, children: [widget])));
        }
      }
      layout.col += colsize;
    }
    if (currentrow != null) {
      result.add(Row(
        mainAxisSize: MainAxisSize.max,
        children: currentrow,
      ));
    }
    return result;
  }

  _getWidget(BuildContext context, C c, int size, double realw) {
    if (c.data is Widget? Function()) {
      return (c.data as Widget? Function()).call();
    }
    if (c.data is R) {
      return _doLayoutRow(context, c.data as R, size,
          BoxConstraints(maxWidth: realw), _Layout());
    } else if (c.data is List<R>) {
      return _doLayoutArray(context, c.data as List<R>, size,
          BoxConstraints(maxWidth: realw), _Layout());
    }
    return null;
  }
}
