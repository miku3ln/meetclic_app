import 'package:flutter/material.dart';

class AppConfig extends ChangeNotifier {
  Locale _locale = const Locale('es');
  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners(); // 🔁 para que toda la app reaccione
  }
}