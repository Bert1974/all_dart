import 'package:flutter/material.dart';

import 'window.base.dart';

/// The Widget that configures your application.
class MyWindow extends BaseMyWindow<MyWindow> {
  const MyWindow({super.key});

  @override
  State<MyWindow> createState() => _MyWindowState();
}

class _MyWindowState extends BaseMyWindowState<MyWindow> {}
