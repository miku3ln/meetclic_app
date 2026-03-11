import 'package:flutter/material.dart';

import '../../app/di/app_providers.dart';
import '../../domain/models/user_data_login.dart';
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
  UserDataLogin? _currentUser;
  UserDataLogin? get currentUser => session.currentSession;

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
    goToGate();
    notifyListeners();

  }

  // ✅ Navegación global (sin context)
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void goToGate() {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.pushNamedAndRemoveUntil('/gate', (route) => false);
  }
  /// (opcional) helper por si quieres navegar a cualquier ruta
  void goToNamed2(String route, {Object? arguments}) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.pushNamed(route, arguments: arguments);
  }
  void goToNamed(String route, {Object? arguments}) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.pushNamed(route, arguments: arguments);
  }
  /// (Opcional) si algún día necesitas limpiar sin navegar
  Future<void> logoutSilently() async {
    await session.clearSession();
    notifyListeners();
  }

  bool get isLoginRequired => startPolicy == AppStartPolicy.requireLogin;

// si quieres el modo “alto nivel” para comparar fácil:
  AppMode get appMode =>
      (startPolicy == AppStartPolicy.requireLogin &&
          afterLoginDestination == AppAfterLoginDestination.pointSale)
          ? AppMode.requireLoginPos
          : AppMode.guestHome;


  void closeDrawerIfOpen() {
    navigatorKey.currentState?.maybePop();// si el drawer está abierto, esto lo cierra
  }
  void goToNamedReplacement(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }
}