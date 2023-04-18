import 'package:flutter/material.dart';
import 'package:main/main.dart';

class AboutPage extends AppPageStatefulWidget<AboutPage> {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();

  @override
  Widget title(BuildContext context) =>
      Text(AppLocalizations.of(context)!.appTitle);
}

class _AboutPageState extends State<AboutPage> {
  /* int disabled = 0;

  bool get isDisbled => disabled > 0;

  List<R> _layout(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    return [
    ];
  }*/
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final translations = AppLocalizations.of(context)!;
    return widget.pageForScroll(Container(
        alignment: Alignment.center, child: Column(children: const [])));
  }
}
