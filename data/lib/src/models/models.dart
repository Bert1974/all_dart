import 'package:data/data.dart';
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

class ServerOS {
  static final int mac = 1;
  static final int linux = 2;
  static final int windows = 4;
}

abstract class BaseModel {
  bool canAccess(User user) {
    return ((this as dynamic).users as ToMany<UserModel>)
            .any((u) => u.id == user.id) ||
        user.roles.any((r) => ((this as dynamic).roles as ToMany<RoleModel>)
            .any((r2) => r2.tag == r)) ||
        user.permissions.any((p) =>
            ((this as dynamic).permissions as ToMany<PermissionModel>)
                .any((p2) => p2.tag == p));
  }

  void created(UserModel user) {
    ((this as dynamic).createdBy as ToOne<UserModel>).target = user;
    (this as dynamic).createdAt = DateTime.now();
    ((this as dynamic).users as ToMany<UserModel>).add(user);
  }
}

/*class ServerConnectionTypes { login
  static int localhost, ssh }
*/
@Entity()
class ServerModel extends BaseModel {
  @Id()
  int id;

  late String name;
  late String? server;
  @Transient() // null for localhost
  late ServerOSTypes os;

  ServerModel(
      {this.id = 0,
      this.name = "",
      this.server,
      this.os = ServerOSTypes.windows,
      this.createdAt});

  final createdBy = ToOne<UserModel>();

  @Property(type: PropertyType.date)
  late final DateTime? createdAt;

  final users = ToMany<UserModel>();
  final roles = ToMany<RoleModel>();
  final permissions = ToMany<PermissionModel>();

  // ...and define a field with a supported type,
  // that is backed by the role field.
  int get dbOs {
    return os.index;
  }

  set dbOs(int value) {
    os = ServerOSTypes.values[value]; // throws a RangeError if not found

    // or if you want to handle unknown values gracefully:
    os = value >= 0 && value < ServerOSTypes.values.length
        ? ServerOSTypes.values[value]
        : ServerOSTypes.linux;
  }
}
/*
@Entity()
class ServerConnectionModel {
  @Id()
  int id = 0;

  late String name;
  late int type;

  ServerConnectionModel({this.name = "", this.type = 0});
}*/
/* 
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
*/
/*
        @Index // Improves query performance at the cost of storage space.
        var date: Date? = null*/