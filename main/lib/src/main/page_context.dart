import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_page.dart';

class PageContext {
  final List<AppPageState> _pages = [];

  static PageContext? of(BuildContext context) =>
      Provider.of<PageContext?>(context, listen: false);

  void register(AppPageState state) {
    if (!_pages.contains(state)) {
      _pages.add(state);
    }
  }

  void unregister(AppPageState state) {
    if (_pages.contains(state)) {
      _pages.remove(state);
    }
  }

  BuildContext? get context {
    return _pages
        // ignore: unnecessary_cast
        .map((e) => e as AppPageState?)
        .firstWhere((element) => element!.mounted, orElse: () => null)
        ?.context;
  }
}
