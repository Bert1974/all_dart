import 'package:flutter/material.dart';

import 'app.dart';

/// The Widget that configures your application.
class BaseMyWindow<T extends BaseMyWindow<T>> extends StatefulWidget {
  const BaseMyWindow({super.key});

  @override
  State<T> createState() => BaseMyWindowState<T>();
}

class BaseMyWindowState<T extends BaseMyWindow<T>> extends State<T> {
  @override
  Widget build(BuildContext context) => const MyApp();
}
