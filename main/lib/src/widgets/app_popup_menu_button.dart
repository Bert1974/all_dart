import 'package:flutter/material.dart';

class AppPopupMenuButton<T> extends StatelessWidget {
  final Icon? icon;
  final Function(T value) onSelected;
  final PopupMenuItemBuilder<T> itemBuilder;

  const AppPopupMenuButton(
      {super.key,
      this.icon,
      required this.onSelected,
      required this.itemBuilder});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 28, maxWidth: 28),
      child: PopupMenuButton(
        key: key,
        icon: icon,
        onSelected: onSelected,
        itemBuilder: itemBuilder,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        offset: Offset.zero,

        splashRadius: null,
        //    iconSize: 20,
      ));
}
