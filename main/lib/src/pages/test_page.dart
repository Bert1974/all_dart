import 'package:flutter/material.dart';
import 'package:main/src/widgets.dart';

class TestPage extends AppPageStatefulWidget<TestPage> {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();

  @override
  Widget get title => const Text("Still testing");
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
