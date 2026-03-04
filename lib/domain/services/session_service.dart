import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/user_data_login.dart';

/// SessionService reactivo con ChangeNotifier
class SessionService extends ChangeNotifier {
  // ✅ Ahora es observable
  static final SessionService _instance = SessionService._internal();

  factory SessionService() => _instance;

  SessionService._internal();

  UserDataLogin? _usuarioLogin;

  Future<void> saveSession(UserDataLogin usuarioLogin) async {
    _usuarioLogin = usuarioLogin;

    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(usuarioLogin.toJson()); // ✅ Guarda datos reales
    await prefs.setString('usuario_login', userJson);
    _hydrated = true; // ✅ ya está cargada/definida la sesión
    notifyListeners(); // ✅ Ahora sí, actualiza la UI automáticamente
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('usuario_login');
    if (userJson != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(userJson);
      _usuarioLogin = UserDataLogin.fromJson(jsonMap);
    } else {
      _usuarioLogin = null;
    }
    _hydrated = true; // ✅ ya está listo para decidir el Gate
    notifyListeners();
  }

  UserDataLogin? get currentSession => _usuarioLogin;

  String? get apiToken => _usuarioLogin?.accessToken;

  bool get isLoggedIn => _usuarioLogin != null;

  Future<void> clearSession() async {
    _usuarioLogin = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_login');
    _hydrated = true; // ✅ importante: no volver a "no cargado"
    notifyListeners(); // ✅ Notifica al cerrar sesión
  }

  bool _hydrated = false; // ✅ indica si ya se leyó SharedPreferences

  bool get hydrated => _hydrated;

  Future<void> ensureLoaded() async {
    if (_hydrated) return;
    await loadSession();
  }

  String get displayName {
    final u = _usuarioLogin;
    if (u == null) return 'Invitado';

    final full = '${u.personName ?? ''} ${u.lastName ?? ''}'.trim();
    if (full.isNotEmpty) return full;

    return u.userName;
  }

  String get displayEmail => _usuarioLogin?.email ?? 'Sin sesión';

  String get displayBusiness =>
      _usuarioLogin?.businessName ?? _usuarioLogin?.businessReason ?? '';

  String get displayRole => _usuarioLogin?.roleName ?? '';

  String? get avatarUrl => _usuarioLogin?.avatar;
}
