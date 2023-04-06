import 'package:flutter/material.dart';
import 'package:main/main.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return const Text(
      "HELLO!",
      //     style: Theme.of(context).textTheme.body1,
    );
  }
}
