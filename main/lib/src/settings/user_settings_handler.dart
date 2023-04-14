import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:provider/provider.dart';

class UserSettingsHandler {
  final DBHandler _db;
  final AuthenticationHandler _auth;
  late final ThemeController themeController;

  void listen() {
    themeController.loadSettings();

    //  updateLanguage(themeController.language);
  }

  UserSettingsHandler(this._db, this._auth) {
    _auth.addListener(listen);
    themeController = ThemeController(this);
    listen();
  }
  void dispose() {
    _auth.removeListener(listen);
  }

  Map<String, dynamic>? settings(String type) {
    var result = _auth.value.user?.userData
        .map<UserSettings?>((e) => e)
        .singleWhere((e) => e!.type == type, orElse: () => null);
    return result?.data;
  }

  FutureOr<bool> updateSettings(String type, Map<String, dynamic> data) async {
    if (_auth.value.user != null) {
      var saveOk = await _db.saveUserSettings(_auth.value.user!, type, data);

      if (saveOk.result ?? false) {
        await _auth.refresh();
        return true;
      }
    }
    return false;
  }

  static UserSettingsHandler of(BuildContext context) =>
      Provider.of<UserSettingsHandler>(context, listen: false);
}
