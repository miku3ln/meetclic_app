import 'package:flutter/material.dart';

import '../../domain/services/session_service.dart';
import '../models/app_config.dart';

/// 🔒 IMPORTANTE:
/// - Por defecto NO obliga login (igual que tu app actual)
/// - Por defecto Splash es la entrada
enum AppStartPolicy {
  allowGuest,     // ✅ default: igual que ahora
  requireLogin,   // 🔁 nuevo proceso cuando lo actives
}
enum AppAfterLoginDestination { home, pointSale }
class DrawerItemDef {
  final String id;
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const DrawerItemDef({
    required this.id,
    required this.title,
    required this.icon,
    this.onTap,
  });
}

class AppController extends ChangeNotifier {
  final AppConfig config;
  final SessionService session;

  AppController({
    required this.config,
    required this.session,
  });

  // ✅ DEFAULT = comportamiento actual (NO login obligatorio)
  AppStartPolicy startPolicy = AppStartPolicy.allowGuest;
  // ✅ configurable: a dónde ir cuando hay login
  AppAfterLoginDestination afterLoginDestination = AppAfterLoginDestination.home;
  // ✅ Menú por defecto como lo tienes
  bool enableDrawer = false;
  String drawerTitle = 'Unit Menu';

  List<DrawerItemDef> drawerItems = const [
    DrawerItemDef(id: 'start', title: 'Start Lesson', icon: Icons.play_arrow),
    DrawerItemDef(id: 'progress', title: 'Progress', icon: Icons.history),
  ];

  // --- Helpers (solo lectura) ---
  bool get isLoggedIn => session.isLoggedIn;

  /// ✅ Por defecto será FALSE (no obliga login)
  bool get shouldShowLogin =>
      startPolicy == AppStartPolicy.requireLogin && !isLoggedIn;

  // --- Cambios (solo si tú los llamas) ---
  void enableRequireLogin() {
    startPolicy = AppStartPolicy.requireLogin;
    notifyListeners();
  }

  void disableRequireLogin() {
    startPolicy = AppStartPolicy.allowGuest;
    notifyListeners();
  }

  void setDrawerEnabled(bool value) {
    enableDrawer = value;
    notifyListeners();
  }

  void setDrawerTitle(String value) {
    drawerTitle = value;
    notifyListeners();
  }

  void setDrawerItems(List<DrawerItemDef> items) {
    drawerItems = items;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    config.setLocale(locale);
    notifyListeners();
  }

  Future<void> logout() async {
    await session.clearSession();
    notifyListeners();
  }
}