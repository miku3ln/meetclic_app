import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings; // 👈 cambio importante

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  Future<bool> load() async {
    String nameJson="";
    if(locale.languageCode=='it'){
       nameJson="ki";
    }else{
      nameJson= locale.languageCode;
    }
    final jsonString =
    await rootBundle.loadString('assets/lang/$nameJson.json');
    _localizedStrings = json.decode(jsonString); // 👈 se mantiene como Map<String, dynamic>
    return true;
  }

  /// Soporta claves anidadas como 'login.buttonLogin' o 'pages.shop'
  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;

    for (final part in keys) {
      if (value is Map<String, dynamic> && value.containsKey(part)) {
        value = value[part];
      } else {
        return key; // si no encuentra la clave, devuelve el mismo texto
      }
    }

    return value is String ? value : key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['es', 'en', 'it'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
