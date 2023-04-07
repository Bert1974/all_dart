import 'package:flutter/material.dart';

abstract class AppPageWidget {
  Widget get title;
}

abstract class AppPageStatefulWidget<T extends StatefulWidget>
    extends StatefulWidget implements AppPageWidget {
  const AppPageStatefulWidget({super.key});
}

abstract class AppPageStatefulWidgetState<T extends StatefulWidget>
    extends State<T> {}

abstract class AppPageStatelessWidget extends StatelessWidget
    implements AppPageWidget {
  const AppPageStatelessWidget({super.key});
}
