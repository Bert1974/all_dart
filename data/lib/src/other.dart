import 'package:data/data.dart';
import 'package:data/src/localization/messages_nl.i18n.dart';

class Result<T> {
  final T? result;
  final String? error;

  Result._({this.result, this.error});

  factory Result.value(T result) => Result._(result: result);
  factory Result.error(String error) => Result._(error: error);
  factory Result.network(NetworkResponse res) => Result._(error: res.message);
}

class MessagesHelper {
  static final List<Messages> _languages = [
    const Messages(),
    const MessagesNl(),
  ];
  static Messages forLocale(String? languageCode) =>
      languageCode == null || languageCode.isEmpty
          ? getDefault()
          : _languages.singleWhere(
              (element) => element.languageCode.startsWith(languageCode),
              orElse: () => getDefault());

  static Messages getDefault() => _languages[0];
}

extension MessagesStringExtension on String {
  Messages get messages => MessagesHelper.forLocale(this);
  NetworkMessages get network => messages.network;
}
