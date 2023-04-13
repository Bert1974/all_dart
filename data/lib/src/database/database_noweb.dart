import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:data/objectbox.g.dart';

import 'package:data/src/models/models.dart';

Database? openStore_(String? databaseDirectory) =>
    ObjectBoxDatabase(databaseDirectory ?? '');

extension UserModelExtension on UserModel {
  User toVM(LoginModel login) => User(
      id: id,
      name: login.name,
      firstName: profile.target!.firstName,
      infix: profile.target!.infix,
      lastName: profile.target!.lastName,
      roles: roles.map((r) => r.tag).toList(),
      permissions: permissions.map((r) => r.tag).toList(),
      userData: preferences.map((i) => i.toVM()).toList());
}

extension UserSettingsModelExtension on UserSettingsModel {
  UserSettings toVM() => UserSettings.fromJsonString(type, data);
}

class ObjectBoxDatabase extends Database {
  final String databaseDirectory;
  static Store? storeInstance;
  Store? _store;
  Box<UserModel>? usersBox;
  Box<UserSettingsModel>? userDataBox;
  Box<LoginModel>? loginsBox;
  Box<RoleModel>? rolesBox;
  Box<PermissionModel>? permissionBox;
  late final Messages? _messages;
  final ObjectBoxDatabase? _main;

  Store? get store => _main?._store ?? _store;

  ObjectBoxDatabase(this.databaseDirectory)
      : _messages = null,
        _main = null;

  ObjectBoxDatabase._forLocaleTag(ObjectBoxDatabase network, String localeTag)
      : databaseDirectory = network.databaseDirectory,
        _store = network.store,
        usersBox = network.usersBox,
        userDataBox = network.userDataBox,
        loginsBox = network.loginsBox,
        rolesBox = network.rolesBox,
        permissionBox = network.permissionBox,
        _main = network {
    //
    _messages = localeTag.messages;
  }

  @override
  Database forLocaleTag(String localeTag) {
    return ObjectBoxDatabase._forLocaleTag(this, localeTag);
  }

  Future<void> close() async {
    if (_main != null) {
      await _main!.close();
      return;
    }
    _store?.close();
    _store = null;
  }

  @override
  ByteData getReference() {
    return storeInstance!.reference;
  }

  @override
  void setReference(ByteData reference) {
    if (_main != null) {
      _main!.setReference(reference);
      return;
    }
    _store = Store.fromReference(getObjectBoxModel(), reference);
    _init();
  }

  @override
  FutureOr<Result<bool>> open() async {
    try {
      storeInstance = openStore(directory: databaseDirectory);
      _store = storeInstance;
      if (_main != null) {
        _main!._store = store;
        _main!._init();
        _main!.seed();
        return Result.value(true);
      }
      _init();
      seed();
      return Result.value(true);
    } catch (e) {
      //
      print(e);
      return Result<bool>.error(_messages!.general.cantopen('ObjectBox'));
    } finally {}
  }

  @override
  void dispose() {
    if (_main != null) {
      throw UnsupportedError('wrong usage');
    }
    if (storeInstance != null) {
      storeInstance!.close();
      storeInstance = null;
    }
  }

  _init() {
    usersBox = store!.box<UserModel>();
    userDataBox = store!.box<UserSettingsModel>();
    loginsBox = store!.box<LoginModel>();
    rolesBox = store!.box<RoleModel>();
    permissionBox = store!.box<PermissionModel>();
  }

  @override
  void seed() {
    print('seeding');
    _syncRoles([
      ["Administrators", Roles.admin]
    ]);
    _tryAdduser("Bert", "123", [Roles.admin]);
  }

  _syncRoles(List<List<String>> roles) {
    for (var current in rolesBox!.getAll()) {
      if (roles.where((l) => l[1] == current.tag).isEmpty) {
        rolesBox!.remove(current.id);
      }
    }
    for (var role in roles) {
      if (rolesBox!
          .query(RoleModel_.tag.equals(role[1]))
          .build()
          .find()
          .isEmpty) {
        rolesBox!.put(RoleModel(role[0], role[1]));
      }
    }
  }

  _tryAdduser(String login, String password, List<String> roles) {
    var login_ = loginsBox!
        .query(LoginModel_.modeltype.equals(Logins.user) &
            LoginModel_.name.equals(login))
        .build()
        .findFirst();
    late UserModel user;
    if (login_ == null) {
      user = UserModel();
      user.login.target = LoginModel(Logins.user, login, password);
      user.profile.target = UserPofileModel();
      usersBox!.put(user);
    } else {
      user = usersBox!
          .query(UserModel_.login.equals(login_.id))
          .build()
          .findFirst()!;
    }
    for (var current in user.roles) {
      if (roles.where((l) => l == current.tag).isEmpty) {
        user.roles.remove(current);
      }
    }
    for (var role in roles) {
      if (user.roles.where((u) => u.tag == role).isEmpty) {
        var r =
            rolesBox!.query(RoleModel_.tag.equals(role)).build().findFirst()!;
        user.roles.add(r);
      }
    }
    usersBox!.put(user);
  }

  Future<LoginModel?> _getLogin(String type, String name) async {
    var q = loginsBox!
        .query(
            LoginModel_.name.equals(name) & LoginModel_.modeltype.equals(type))
        .build();
    return await q.findFirstAsync();
  }

  @override
  FutureOr<Result<User>> login(String name, String password) async {
    final result = await _getLogin(Logins.user, name);

    if (result != null) {
      if (result.password == password) {
        var q2 = usersBox!.query(UserModel_.login.equals(result.id)).build();
        UserModel user = (await q2.findFirstAsync())!;
        return Result.value(user.toVM(result));
      }
    }
    return Result.error("no access");
  }

  @override
  Future<User?> checkToken(String name, String token) async {
    final result = await _getLogin(Logins.user, name);
    if (result != null) {
      var q2 = usersBox!.query(UserModel_.login.equals(result.id)).build();
      UserModel user = (await q2.findFirstAsync())!;
      return user.toVM(result);
    }
    return null;
  }

  @override
  Future<User?> check(User user) async {
    final result = await _getLogin(Logins.user, user.name);
    if (result != null) {
      var q2 = usersBox!.query(UserModel_.login.equals(result.id)).build();
      UserModel user_ = (await q2.findFirstAsync())!;

      if (user_.id == user.id) {
        return user_.toVM(result);
      }
    }
    return null;
  }

  @override
  Future<bool> saveUserSettings(
      User user, String type, Map<String, dynamic> data) async {
    UserModel user2 = usersBox!.get(user.id)!;
    UserSettingsModel? data_ = user2.preferences
        // ignore: unnecessary_cast
        .map((e) => e as UserSettingsModel?)
        .firstWhere((element) => element!.type == type, orElse: () => null);
    if (data_ == null) {
      data_ = UserSettingsModel(id: 0, type: type, data: json.encode(data));
      user2.preferences.add(data_);
      await usersBox!.putAsync(user2);
    } else {
      data_.data = json.encode(data);
      await userDataBox!.putAsync(data_);
    }
    return true;
  }
}
