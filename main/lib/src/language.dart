import 'package:flutter/material.dart';

class Language {
  final String description;
  final Locale locale;

  const Language(this.locale, this.description);

  @override
  bool operator ==(Object other) =>
      other is Language &&
      description == other.description &&
      locale.languageCode == other.locale.languageCode &&
      locale.countryCode == other.locale.countryCode;

  @override
  int get hashCode => description.hashCode ^ locale.hashCode;

  static Language? fromJson(Map<String, dynamic>? json) => json == null
      ? null
      :
      // ignore: unnecessary_cast
      languages.map<Language?>((e) => e as Language?).singleWhere(
              (element) =>
                  element!.locale.languageCode == json['language'] &&
                  element.locale.countryCode == json['country'],
              orElse: () => null) ??
          languages[0];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'language': locale.languageCode,
        'country': locale.countryCode
      };

  String toLanguageTag() => locale.toLanguageTag();
}

List<Language> languages = const [
  Language(Locale('nl', ''), "Nederlands"),
  Language(Locale('en', ''), "English"),
];
