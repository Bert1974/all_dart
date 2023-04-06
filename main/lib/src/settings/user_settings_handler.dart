import 'dart:convert';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/src/settings/theme_controller.dart';
import 'package:provider/provider.dart';

import 'authentication.dart';

class UserSettingsHandler {
  final NetworkHandler network;
  late final ThemeController themeController;
  User? user;

  void listen() {
    user = network.auth.value.user;
    themeController.loadSettings();
  }

  UserSettingsHandler(this.network) {
    network.auth.addListener(listen);
    themeController = ThemeController(this);
    listen();
  }
  void dispose() {
    network.auth.removeListener(listen);
  }

  Map<String, dynamic>? settings(String type) {
    String? json_ = user?.userData
        .map<UserSettings?>((e) => e)
        .singleWhere((e) => e!.type == type, orElse: () => null)
        ?.data;

    if (json_ != null) {
      return json.decode(json_);
    }
    return null;
  }

  Future<bool> updateSettings(String type, Map<String, dynamic> data) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.

    var res =
        await network.postData('user/setting', {'type': type, 'data': data});

    if (res.success) {
      await network.auth.refresh(network);
      return true;
    }
    return false;
  }

  static UserSettingsHandler of(BuildContext context) =>
      Provider.of<UserSettingsHandler>(context, listen: false);
}
