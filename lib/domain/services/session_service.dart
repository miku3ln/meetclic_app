import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/user_data_login.dart';

/// SessionService reactivo con ChangeNotifier
class SessionService extends ChangeNotifier {   // ✅ Ahora es observable
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  UserDataLogin? _usuarioLogin;

  Future<void> saveSession(UserDataLogin usuarioLogin) async {
    _usuarioLogin = usuarioLogin;

    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(usuarioLogin.toJson());  // ✅ Guarda datos reales
    await prefs.setString('usuario_login', userJson);

    notifyListeners();   // ✅ Ahora sí, actualiza la UI automáticamente
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('usuario_login');
    if (userJson != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(userJson);
      _usuarioLogin = UserDataLogin.fromJson(jsonMap);

      notifyListeners();  // ✅ Notifica al cargar sesión desde memoria
    }
  }

  UserDataLogin? get currentSession => _usuarioLogin;
  String? get apiToken => _usuarioLogin?.accessToken;
  bool get isLoggedIn => _usuarioLogin != null;

  Future<void> clearSession() async {
    _usuarioLogin = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_login');

    notifyListeners();  // ✅ Notifica al cerrar sesión
  }
}
