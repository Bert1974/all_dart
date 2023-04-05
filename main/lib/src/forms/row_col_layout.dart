import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';

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
    if (offsets != null) {
      if (size >= 5 && offsets!.containsKey('xxl')) {
        return offsets!['xxl']!;
      } else if (size >= 4 && offsets!.containsKey('xl')) {
        return offsets!['xl']!;
      } else if (size >= 3 && offsets!.containsKey('lg')) {
        return offsets!['lg']!;
      } else if (size >= 2 && offsets!.containsKey('md')) {
        return offsets!['md']!;
      } else if (size >= 1 && offsets!.containsKey('sm')) {
        return offsets!['sm']!;
      } else if (size >= 0 && offsets!.containsKey('xs')) {
        return offsets!['xs']!;
      }
    }
    return 0;
  }

  int getSize(int size, _Layout layout) {
    if (sizes != null) {
      if (size >= 5 && sizes!.containsKey('xxl')) {
        return sizes!['xxl']!;
      } else if (size >= 4 && sizes!.containsKey('xl')) {
        return sizes!['xl']!;
      } else if (size >= 3 && sizes!.containsKey('lg')) {
        return sizes!['lg']!;
      } else if (size >= 2 && sizes!.containsKey('md')) {
        return sizes!['md']!;
      } else if (size >= 1 && sizes!.containsKey('sm')) {
        return sizes!['sm']!;
      } else if (size >= 0 && sizes!.containsKey('xs')) {
        return sizes!['xs']!;
      } else {
        return 1;
      }
    }
    return 0;
  }
}

class RowColLayout extends StatelessWidget {
  final List<R> layout;
  final Widget? Function(dynamic data)? lookupfunction;
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

      return _doLayoutArray(layout, size, constraints, _Layout());
    });
  }

  Widget _doLayoutArray(
      List<R> rows, int size, BoxConstraints constraints, _Layout layout) {
    List<Widget> result = [];

    for (var row in rows) {
      result.addAll(_doLayoutRow(row, size, constraints, layout));
    }
    return Column(children: result);
  }

  List<Widget> _doLayoutRow(
      R row, int size, BoxConstraints constraints, _Layout layout) {
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
      var widget =
          ((column.data != null) ? lookupfunction?.call(column.data) : null) ??
              _getWidget(column, size, realw);
      if (widget is List<Widget>) {
        currentrow.add(SizedBox(
            width: realw,
            child: Column(mainAxisSize: MainAxisSize.max, children: widget)));
      } else {
        currentrow.add(SizedBox(
            width: realw,
            child: Column(mainAxisSize: MainAxisSize.max, children: [widget])));
      }
      layout.col += colsize;
    }
    if (currentrow != null) {
      result.add(Row(children: currentrow));
    }
    return result;
  }

  _getWidget(C c, int size, double realw) {
    if (c.data is R) {
      return _doLayoutRow(
          c.data as R, size, BoxConstraints(maxWidth: realw), _Layout());
    } else if (c.data is List<R>) {
      return _doLayoutArray(
          c.data as List<R>, size, BoxConstraints(maxWidth: realw), _Layout());
    }
    throw UnsupportedError('Not implmented');
  }
}
