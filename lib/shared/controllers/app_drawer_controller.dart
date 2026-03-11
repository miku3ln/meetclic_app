import 'package:flutter/material.dart';

import '../../app/router/app_router.dart';
import 'app_controller.dart';
enum DrawerNavigationMode {
  replace,
  push,
}
class AppDrawerItem {
  final String id;
  final String title;
  final IconData icon;
  final String routeName;

  /// permisos simples
  final bool requireLogin;
  final DrawerNavigationMode navigationMode;
  const AppDrawerItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.routeName,
    this.requireLogin = false,
    this.navigationMode = DrawerNavigationMode.replace,
  });
}

class AppDrawerController extends ChangeNotifier {
  final AppController app;

  AppDrawerController({required this.app});

  // cuál está activo
  String _selectedId = 'pos';

  String get selectedId => _selectedId;

  // items (config central)
  late final List<AppDrawerItem> items = [
    AppDrawerItem(
      id: 'pos',
      title: 'Punto de Venta',
      icon: Icons.point_of_sale_rounded,
      routeName: AppRoutes.pos,
      requireLogin: true, // POS solo con login (si quieres)
      navigationMode: DrawerNavigationMode.replace,
    ),
    AppDrawerItem(
      id: 'settings',
      title: 'Settings & account',
      icon: Icons.settings,
      routeName: AppRoutes.settings,
      navigationMode: DrawerNavigationMode.push,
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
  void onItemTap(BuildContext context,AppDrawerItem item) {
    if (item.requireLogin && !app.isLoggedIn) {
      Navigator.of(context).pop();
      Future.microtask(() => app.goToGate());
      return;
    }

    _selectedId = item.id;
    notifyListeners();

    Navigator.of(context).pop();

    Future.microtask(() {
      switch (item.navigationMode) {
        case DrawerNavigationMode.replace:
          app.goToNamedReplacement(item.routeName);
          break;
        case DrawerNavigationMode.push:
          app.goToNamed(item.routeName);
          break;
      }
    });
  }

  void setSelected(String id) {
    _selectedId = id;
    notifyListeners();
  }
}
