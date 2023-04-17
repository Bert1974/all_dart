import 'dart:async';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'package:provider/provider.dart';

class DBHandler {
  Database? _dbMain;
  Database? _db;
  AppLocalizations? _translations;
  DBHandler();

//  get

  static DBHandler of(BuildContext context) =>
      Provider.of<DBHandler>(context, listen: false);

  FutureOr<Result<bool>> open(
    BuildContext context,
    DatabaseTypes type,
    Map<String, dynamic> options,
  ) async {
    var themeController = ThemeController.of(context);
    Database? db_;

    _translations = AppLocalizations.of(context)!;

    switch (type) {
      case DatabaseTypes.local:
        db_ = Database.openStore(options['database']).result;
        break;
      case DatabaseTypes.network:
        db_ = Database.openNetwork(options['server']);
        break;
    }
    if (db_ == null) {
      return Result.value(false);
    }
    _dbMain?.dispose();
    _dbMain = null;
    _db = null;

    var r = await db_.forLocaleTag(themeController.localeTag).open();

    if (r.result ?? false) {
      _dbMain = db_;
      _db = _dbMain!.forLocaleTag(themeController.localeTag);
      return r;
    }
    _dbMain?.dispose();
    _dbMain = null;
    return r;
    // User? user = await db_.login(login.name, login.password);
  }

  void updateLanguage(BuildContext context, String localeTag) {
    _db = _dbMain?.forLocaleTag(localeTag);
    _translations = AppLocalizations.of(context)!;
  }

  Future<Result<T>> _dbcall<T>(
      User? user, Future<Result<T>> Function() action) async {
    if (_db != null) {
      if (user != null) {
        return await action();
      }
      return Result<T>.error(_db!.messages.general.unauthenticated);
    }
    return Result<T>.error(_translations!.notLoggedIn);
  }

  Future<Result<List<Server>>> getServers(User? user) async {
    return await _dbcall(user, () async => await _db!.getServers(user!));
  }

  Future<Result<bool>> saveUserSettings(
      User user, String type, Map<String, dynamic> data) async {
    return await _dbcall<bool>(
        user, () async => await _db!.saveUserSettings(user, type, data));
  }

  FutureOr<Result<User>> login(String name, String password) async {
    if (_db!=null){
      return await _db!.login(name, password);
    }
    return Result<User>.error('not initialized');
  }

  FutureOr<User?> checkUser(User user) {
    return _db!.check(user);
  }
}
