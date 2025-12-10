import 'package:flutter/material.dart';

class AppConfig extends ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;
  String urlFlag = "";

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners(); // 🔁 para que toda la app reaccione
  }

  String getUrlFlag() {
    final rawLocale = this.locale.languageCode; // 'es', 'en', 'ki', etc.
    final locale = rawLocale != 'it' ? rawLocale : 'ki';
    urlFlag = 'assets/flags/$locale.png';
    return urlFlag;
  }
}
