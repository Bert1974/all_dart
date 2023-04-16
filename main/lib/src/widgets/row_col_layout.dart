import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  double cury = 0, maxy = 0, maxw = 0;
  double x = 0;
  RenderBox? _child;
  final _Layout? owner;

  RenderBox? get child => owner?.child ?? _child;
  set child(RenderBox? value) {
    if (owner != null) {
      owner!.child = value;
    } else {
      _child = value;
    }
  }

  _Layout({RenderBox? child, this.owner}) : _child = child;

  void newRow(double rowWidth) {
    var ww = rowWidth * 12;
    if (maxw < ww) {
      maxw = ww;
    }
    row++;
    col = 0;
    cury += maxy;
    maxy = 0;
    x = 0;
  }

  Size pop() {
    owner!.cury += cury;

    if (owner!.maxw < maxw) {
      owner!.maxw = maxw;
    }
    return Size(maxw, cury);
  }

  //Size toSize() => Size(maxw, cury);
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

class RowColLayout extends StatefulWidget {
  final List<R> layout;
  final Widget? Function(BuildContext context, dynamic data)? lookupfunction;
  final bool useScreenSize;
  const RowColLayout(
      {super.key,
      required this.layout,
      this.lookupfunction,
      this.useScreenSize = true});

  @override
  State<RowColLayout> createState() => _RowColLayoutState();
}

class _RowColLayoutState extends State<RowColLayout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyMultiChildRenderObjectWidget(
        context: context,
        layout: widget.layout,
        children: _initializeArray(widget.layout));
  }

  List<Widget> _initializeArray(List<R> rows) {
    List<Widget> result = [];
    for (var row in rows) {
      result.addAll(_initalizeRow(row));
    }
    return result;
  }

  List<Widget> _initalizeRow(R row) {
    List<Widget> result = [];
    for (var column in row.columns) {
      if (column.data != null) {
        if (column.data is R) {
          result.addAll(_initalizeRow(column.data as R));
        } else if (column.data is List<R>) {
          result.addAll(_initializeArray(column.data as List<R>));
        } else {
          Widget? w;
          if (widget.lookupfunction != null) {
            w = widget.lookupfunction!.call(context, column.data);
          }
          if (w == null) {
            if (column.data is Widget? Function(BuildContext context)) {
              w = (column.data as Widget? Function(BuildContext context))
                  .call(context);
            }
          }
          if (w == null) {
            throw Exception('');
          }
          result.add(w);
        }
      }
    }
    return result;
  }
}

class MyParentData extends ContainerBoxParentData<RenderBox> {}

class MyRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MyParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MyParentData> {
  final List<R> layout_;

  MyRenderBox({required this.layout_});

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! MyParentData) {
      child.parentData = MyParentData();
    }
  }

  @override
  @protected
  Size computeDryLayout(BoxConstraints constraints) {
    var w = constraints.maxWidth;
    int size_ = getSize(w);
    RenderBox? child = firstChild;
    if (child != null) {
      var l = _Layout(child: child);
      return _computeDryLayoutArray(layout_, size_, w, l);
    }
    return Size.zero;
  }

  Size _computeDryLayoutArray(
      List<R> rows, int size, double maxsize, _Layout layout_) {
    _Layout layout2 = _Layout(owner: layout_);
    for (var row in rows) {
      _computeDryLayoutRow(row, size, maxsize, layout2);
    }
    if (layout_.maxw < layout2.maxw) {
      layout_.maxw = layout2.maxw;
    }
    return layout2.pop();
  }

  Size _computeDryLayoutRow(R row, int size, double maxsize, _Layout layout_) {
    _Layout layout2 = _Layout(owner: layout_);
    List<C> currentrow = [];
    double rowWidth = 0;

    for (var column in row.columns) {
      int colsize = column.getSize(size, layout2);
      int coloffset = column.getOffset(size, layout2);
      double realw = maxsize * colsize / 12;

      Size widgetSize = Size.zero;

      if (column.data != null) {
        if (column.data is R) {
          widgetSize =
              _computeDryLayoutRow(column.data as R, size, realw, layout2);
        } else if (column.data is List<R>) {
          widgetSize = _computeDryLayoutArray(
              column.data as List<R>, size, realw, layout2);
        } else {
          //if (column._widget != null) {
          final MyParentData childParentData =
              layout2.child!.parentData as MyParentData;

          var widgetHeight = layout2.child!.getMaxIntrinsicHeight(realw);
          var widgetWidth = layout2.child!.getMaxIntrinsicWidth(widgetHeight);

          widgetSize = Size(widgetWidth, widgetHeight);
          //         layout2.child!.getDryLayout(BoxConstraints(maxWidth: realw));

          layout2.child = childParentData.nextSibling;
          // }
        }
      }
      // break, will overthrow
      if (currentrow.isNotEmpty && layout2.col + coloffset + colsize > 12) {
        layout2.newRow(rowWidth);
        currentrow = [];
        rowWidth = 0;
      }
      if (rowWidth < widgetSize.width / colsize) {
        rowWidth = widgetSize.width / colsize;
      }
      if (layout2.maxy < widgetSize.height) {
        layout2.maxy = widgetSize.height;
      }
      //check height for line
      if (layout2.maxy < widgetSize.height) {
        layout2.maxy = widgetSize.height;
      }
      //add offset
      if (coloffset > 0) {
        layout2.col += coloffset;
      }
      currentrow.add(column);

      layout2.col += colsize;
    }
    layout2.newRow(rowWidth);
    return layout2.pop();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  @protected
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void performLayout() {
    var prefsize = computeDryLayout(constraints);

    var w = prefsize.width;

    w = clampDouble(w, constraints.minWidth, constraints.maxWidth);

    int size_ = getSize(w);
    RenderBox? child = firstChild;
    if (child != null) {
      var l = _Layout(child: child);
      Size finalSize = _performLayoutArray(layout_, size_, w, l);

      finalSize = Size(
          clampDouble(
              finalSize.width, constraints.minWidth, constraints.maxWidth),
          clampDouble(
              finalSize.height, constraints.minHeight, constraints.maxHeight));

      if (!sizedByParent) {
        size = finalSize;
      }
    } else {
      if (!sizedByParent) {
        size = Size.zero;
      }
    }
    //  size = Size(constraints.maxWidth, height);
  }

  Size _performLayoutArray(
      List<R> rows, int size, double maxsize, _Layout layout_) {
    _Layout layout2 = _Layout(owner: layout_);
    for (var row in rows) {
      _performLayoutRow(row, size, maxsize, layout2);
    }
    return layout2.pop();
  }

  Size _performLayoutRow(R row, int size, double maxsize, _Layout layout_) {
    _Layout layout2 = _Layout(owner: layout_);
    List<C> currentrow = [];
    double rowWidth = 0;

    for (var column in row.columns) {
      int colsize = column.getSize(size, layout2);
      int coloffset = column.getOffset(size, layout2);
      double realw = maxsize * colsize / 12;

      MyParentData? childParentData;
      RenderBox? child;
      Size widgetSize = Size.zero;

      if (column.data != null) {
        if (column.data is R) {
          widgetSize =
              _performLayoutRow(column.data as R, size, realw, layout2);
        } else if (column.data is List<R>) {
          widgetSize =
              _performLayoutArray(column.data as List<R>, size, realw, layout2);
        } else {
          // if (column._widget != null) {
          child = layout2.child;
          childParentData = child!.parentData as MyParentData;

          child.layout(BoxConstraints(maxWidth: realw), parentUsesSize: true);
          //childConstraints = BoxConstraints.tight(child.size);

          /*widgetSize =
                layoutChild(column._id, BoxConstraints(maxWidth: realw));
            widgetSize =
                layout.child!.getDryLayout(BoxConstraints(maxWidth: realw));
*/
          /*   column._width = realw;*/
          layout2.child = childParentData.nextSibling;

          widgetSize = child.size;
          //   }
        }
      }
      // break, will overthrow
      if (currentrow.isNotEmpty && layout2.col + coloffset + colsize > 12) {
        layout2.newRow(rowWidth);
        currentrow = [];
        rowWidth = 0;
      }
      if (rowWidth < widgetSize.width / colsize) {
        rowWidth = widgetSize.width / colsize;
      }
      //check height for line
      if (layout2.maxy < widgetSize.height) {
        layout2.maxy = widgetSize.height;
      }
      layout2.x += coloffset * maxsize / 12;
      //set position of child
      childParentData?.offset = Offset(layout2.x, layout2.cury);

      layout2.x += realw;

      //add offset
      if (coloffset > 0) {
        layout2.col += coloffset;
      }
      currentrow.add(column);

      layout2.col += colsize;
    }
    layout2.newRow(rowWidth);
    return layout2.pop();
  }

  int getSize(double w) {
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
    return size;
  }
}

class MyMultiChildRenderObjectWidget extends MultiChildRenderObjectWidget {
  final List<R> layout;

  const MyMultiChildRenderObjectWidget(
      {super.key,
      required BuildContext context,
      required super.children,
      required this.layout});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MyRenderBox(layout_: layout);
  }
}
