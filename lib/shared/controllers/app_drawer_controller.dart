import 'package:flutter/material.dart';

import '../../app/router/app_router.dart';
import 'app_controller.dart';

class AppDrawerItem {
  final String id;
  final String title;
  final IconData icon;
  final String routeName;

  /// permisos simples
  final bool requireLogin;

  const AppDrawerItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.routeName,
    this.requireLogin = false,
  });
}
class AppDrawerController extends ChangeNotifier {
  final AppController app;

  AppDrawerController({required this.app});

  // cuál está activo
  String _selectedId = 'home';
  String get selectedId => _selectedId;

  // items (config central)
  late final List<AppDrawerItem> items = [
    AppDrawerItem(
      id: 'pos',
      title: 'Punto de Venta',
      icon: Icons.point_of_sale_rounded,
      routeName: AppRoutes.pos,
      requireLogin: true, // POS solo con login (si quieres)
    ),
    AppDrawerItem(
      id: 'settings',
      title: 'Settings & account',
      icon: Icons.settings,
      routeName: AppRoutes.settings,
    ),
  ];

  /// ✅ set activo desde Splash (_loadResources)
  void setSelectedByRoute(String route) {
    final found = items.where((i) => i.routeName == route).toList();
    if (found.isEmpty) return;
    _selectedId = found.first.id;
    notifyListeners();
  }

  /// ✅ Tap de item
  void onItemTap(AppDrawerItem item) {
    // permiso simple
    if (item.requireLogin && !app.isLoggedIn) {
      // si exige login, vuelve al gate para que muestre login (si tu config es requireLogin)
      app.goToGate();
      return;
    }

    _selectedId = item.id;
    notifyListeners();

    // navega (usa navigatorKey global del AppController)
    app.goToNamed(item.routeName);

    // cierra el drawer si está abierto
    app.closeDrawerIfOpen();
  }
  void setSelected(String id) {
    _selectedId = id;
    notifyListeners();
  }
}