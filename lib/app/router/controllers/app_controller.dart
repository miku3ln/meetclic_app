import 'package:flutter/material.dart';


import '../../../domain/models/user_data_login.dart';
import '../../../domain/services/session_service.dart';
import '../../../shared/models/app_config.dart';
import '../../di/app_providers.dart';
import '../app_router.dart';
import 'app_drawer_controller.dart';

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
  void goToModule(String routeName) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    // 🔥 1. si es la misma ruta → NO HACER NADA
    if (_currentRouteName == routeName) return;

    _currentRouteName = routeName;
    // 🔥 2. regla especial: SALES nunca se empuja
    if (routeName == AppRoutes.sales) {
      nav.popUntil((route) => route.settings.name == AppRoutes.sales);
      return;
    }
    notifyListeners();
    // 🔥 3. resto de módulos → reemplazan
    nav.pushNamedAndRemoveUntil(
      routeName,
          (route) => route.settings.name == AppRoutes.sales,
    );

    notifyListeners();
  }
  String? get currentRouteName => _currentRouteName;

  bool isCurrentRoute(String route) {
    return _currentRouteName == route;
  }

  bool isCurrentDrawerItem(AppDrawerItem item) {
    return item.routeName == _currentRouteName;
  }
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

  void goToNamed(String route, {Object? arguments}) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    _currentRouteName = route;
    notifyListeners();
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
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    _currentRouteName = routeName;
    notifyListeners();
    nav.pushReplacementNamed(routeName, arguments: arguments);
  }
  String? _currentRouteName=AppRoutes.sales;
 // String? get currentRouteName => _currentRouteName;
  void setCurrentRoute(String routeName) {
    _currentRouteName = routeName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  void goToNamedIfNotCurrent(String routeName, {Object? arguments}) {
    if (_currentRouteName == routeName) return;
    goToNamed(routeName, arguments: arguments);
  }
  void goToNamedReplacementIfNotCurrent(String routeName, {Object? arguments}) {
    if (_currentRouteName == routeName) return;
    goToNamedReplacement(routeName, arguments: arguments);
  }
  /// 🔥 IMPORTANTE:
  /// Si la ruta ya existe en el stack, vuelve a esa misma instancia.
  /// Si no existe, la abre nueva.
  void restoreRouteOrPush(String routeName, {Object? arguments}) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    bool found = false;

    nav.popUntil((route) {
      final routeNameInStack = route.settings.name;
      final sameRoute = routeNameInStack == routeName;

      if (sameRoute) {
        found = true;
      }

      return sameRoute || route.isFirst;
    });

    if (found) {
      _currentRouteName = routeName;
      notifyListeners();
      return;
    }

    _currentRouteName = routeName;
    notifyListeners();
    nav.pushNamed(routeName, arguments: arguments);
  }
}
class AppRouteObserver extends NavigatorObserver {
  final AppController app;

  AppRouteObserver(this.app);

  void _update(Route? route) {
    final name = route?.settings.name;
    if (name == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      app.setCurrentRoute(name);
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _update(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _update(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    // 🔥 ESTA ES LA CLAVE REAL
    _update(previousRoute);
  }
}