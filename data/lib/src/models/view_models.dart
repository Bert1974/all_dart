import 'package:json_annotation/json_annotation.dart';

part 'view_models.g.dart';

class UserSettingTypes {
  static final String theme = 'Theme';
}

/*
abstract class FromJSON<T> {
  Map<String, dynamic> toJson();
}

class _Converter<T extends FromJSON<T>>
    implements JsonConverter<List<T>, List<dynamic>?> {
  const _Converter();

  @override
  List<T> fromJson(List<dynamic>? json) {
    print('fromJson');
    print(json);
    if (T is UserSettings) {
      // return UserSettings.fromJson(json as Map<String, dynamic>) as T;
      return json!.map<T>((json) => UserSettings.fromJson(json) as T).toList();
    }
    /* if (json is Map<String, dynamic> &&
        json.containsKey('type') &&
        json.containsKey('data')) {
      }*/
    // This will only work if `json` is a native JSON type:
    //   num, String, bool, null, etc
    // *and* is assignable to `T`.
    throw Exception('help');
    //  return json as T;
  }

  // This will only work if `object` is a native JSON type:
  //   num, String, bool, null, etc
  // Or if it has a `toJson()` function`.
  @override
  List<dynamic> toJson(List<T>? list) {
    print('toJson');
    print(list);
    return (list as List<T>)
        .map<Map<String, dynamic>>((s) => (s).toJson())
        .toList();
  }
}
*/
@JsonSerializable()
class Login {
  late String name, password;

  Login([this.name = "", this.password = ""]);
  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);
  Map<String, dynamic> toJson() => _$LoginToJson(this);
}

@JsonSerializable(explicitToJson: true)
class User {
  int id;
  final String name, firstName, infix, lastName;
  final List<String> roles;
  final List<String> permissions;
  final List<UserSettings> userData;

  User(
      {this.id = 0,
      this.name = "",
      this.firstName = "",
      this.infix = "",
      this.lastName = "",
      this.roles = const [],
      this.permissions = const [],
      this.userData = const []});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserSettings {
  late String? type;
  late String? data;

  UserSettings({this.type, this.data});
  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  @override
  bool operator ==(Object other) =>
      other is UserSettings && other.type == type && other.data == data;

  @override
  int get hashCode => type.hashCode * 31 ^ data.hashCode;
}

/*
@Entity()
class Item {
  @Id()
  int id = 0;

  late String name;
  final allowedRoles = ToMany<Role>();
  final allowedPermissions = ToMany<Permission>();

  Item(this.name);

  /* List<BaseItem> get documents {
    return [];
  }*/
}

abstract class BaseItem {}

abstract class BaseLaunchItem {}

@Entity()
class LaunchItem extends BaseItem implements BaseLaunchItem {
  @Id()
  int id = 0;

  late String command;

  LaunchItem([this.command = ""]);
}

@Entity()
class LaunchRDP extends BaseItem implements BaseLaunchItem {
  @Id()
  int id = 0;

  late String server;
  final login = ToOne<Login>();

  LaunchRDP([this.server = ""]);
}
*/
/*
        @Index // Improves query performance at the cost of storage space.
        var date: Date? = null*/