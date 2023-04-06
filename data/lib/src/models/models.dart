import 'package:objectbox/objectbox.dart';

class Logins {
  static const String user = "User";
}

class UserSettingTypes {
  static const String user = "User";
}

@Entity()
class LoginModel {
  @Id()
  int id = 0;

  late String name, password, modeltype;

  LoginModel(this.modeltype, [this.name = "", this.password = ""]);
}

@Entity()
class UserModel {
  @Id()
  int id = 0;

  final login = ToOne<LoginModel>();
  final roles = ToMany<RoleModel>();
  final permissions = ToMany<PermissionModel>();
  final preferences = ToMany<UserSettingsModel>();
  // final documents = ToMany<Item>();

  final profile = ToOne<UserPofileModel>();
}

@Entity()
class UserSettingsModel {
  @Id()
  int id = 0;

  late String type; // UserSettingTypes
  late String? data;

  UserSettingsModel({this.id = 0, required this.type, this.data});
}

@Entity()
class UserPofileModel {
  @Id()
  int id = 0;

  late String email, phone, firstName, infix, lastName;

  UserPofileModel(
      [this.email = '',
      this.phone = '',
      this.firstName = '',
      this.infix = '',
      this.lastName = '']);
}

class Roles {
  static const String admin = "ADMIN";
  static const String user = "USER";
}
/*
enum Permissions {
  admin,
  user
}*/

@Entity()
class RoleModel {
  @Id()
  int id = 0;

  late String name;
  late String tag;

  RoleModel(this.name, this.tag);
}

@Entity()
class PermissionModel {
  @Id()
  int id = 0;

  late String name;
  late String tag;

  PermissionModel(this.name, this.tag);
}

@Entity()
class ItemModel {
  @Id()
  int id = 0;

  late String name;
  final allowedRoles = ToMany<RoleModel>();
  final allowedPermissions = ToMany<PermissionModel>();

  ItemModel(this.name);

  /* List<BaseItem> get documents {
    return [];
  }*/
}

abstract class BaseItem {}

abstract class BaseLaunchItem {}

@Entity()
class LaunchItemModel extends BaseItem implements BaseLaunchItem {
  @Id()
  int id = 0;

  late String command;

  LaunchItemModel([this.command = ""]);
}

@Entity()
class LaunchRDPModel extends BaseItem implements BaseLaunchItem {
  @Id()
  int id = 0;

  late String server;
  final login = ToOne<LoginModel>();

  LaunchRDPModel([this.server = ""]);
}

/*
        @Index // Improves query performance at the cost of storage space.
        var date: Date? = null*/