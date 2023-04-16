import 'package:flutter/material.dart';

//base
abstract class AppPageWidget {
  Widget title(BuildContext context);

  Widget pageForScroll(Widget child);
}

Widget _pageForScroll(Widget child) => SingleChildScrollView(child: child);

//statefull
abstract class AppPageStatefulWidget<T extends StatefulWidget>
    extends StatefulWidget implements AppPageWidget {
  const AppPageStatefulWidget({super.key});

  @override
  Widget pageForScroll(Widget child) {
    return _pageForScroll(child);
  }
}

abstract class AppPageStatefulWidgetState<T extends StatefulWidget>
    extends State<T> {}

//stateless
abstract class AppPageStatelessWidget extends StatelessWidget
    implements AppPageWidget {
  const AppPageStatelessWidget({super.key});

  @override
  Widget pageForScroll(Widget child) {
    return _pageForScroll(child);
  }
}
