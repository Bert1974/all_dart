import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialogParent extends StatelessWidget {
  final Widget child;
  const DialogParent({super.key, required this.child});

  static BoxConstraints? getConstraints(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_DialogParentValue>()
        ?.pageSize;
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        return _DialogParentValue(pageSize: constraints, child: child);
      });
}

class _DialogParentValue extends InheritedWidget {
  final BoxConstraints pageSize;

  const _DialogParentValue({required this.pageSize, required super.child});

  @override
  @protected
  bool updateShouldNotify(_DialogParentValue oldWidget) {
    return oldWidget.pageSize != pageSize;
  }
}
