import 'dart:async';
import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:data/objectbox.g.dart';

import 'package:data/src/models/models.dart';

Database openStore_() => ObjectBoxDatabase();

extension ModelExtension on UserModel {
  User toVM() => User(
      id: id,
      firstName: profile.target!.firstName,
      infix: profile.target!.infix,
      lastName: profile.target!.lastName,
      roles: roles.map((r) => r.tag).toList(),
      permissions: permissions.map((r) => r.tag).toList());
}

class ObjectBoxDatabase extends Database {
  static const String _databaseFile = "testdatabase";
  static Store? storeInstance;
  Store? store;
  Box<UserModel>? usersBox;
  Box<LoginModel>? loginsBox;
  Box<RoleModel>? rolesBox;
  Box<PermissionModel>? permissionBox;

  ObjectBoxDatabase();

  Future<void> close() async {
    store?.close();
    store = null;
  }

  @override
  ByteData getReference() {
    return storeInstance!.reference;
  }

  @override
  void setReference(ByteData reference) {
    store = Store.fromReference(getObjectBoxModel(), reference);
    _init();
  }

  @override
  FutureOr<void> open() async {
    storeInstance = openStore(directory: _databaseFile);
    store = storeInstance;
    _init();
    seed();
  }

  _init() {
    usersBox = store!.box<UserModel>();
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

  Future<LoginModel?> _getLogin(
      String type, String name, String password) async {
    var q = loginsBox!
        .query(LoginModel_.name.equals(name) &
            LoginModel_.password.equals(password) &
            LoginModel_.modeltype.equals(type))
        .build();
    return await q.findFirstAsync();
  }

  @override
  FutureOr<User?> login(String name, String password) async {
    final result = await _getLogin(Logins.user, name, password);
    if (result != null) {
      var q2 = usersBox!.query(UserModel_.login.equals(result.id)).build();
      UserModel user = (await q2.findFirstAsync())!;
      return user.toVM();
    }
    return null;
  }
}
