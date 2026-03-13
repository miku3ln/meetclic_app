import 'package:flutter/material.dart';

import '../../app/router/app_router.dart';
import 'app_controller.dart';

enum DrawerNavigationMode { replace, push, restoreIfExists }

class AppDrawerItem {
  final String id;
  final String title;
  final IconData icon;
  final String routeName;
  final bool requireLogin;
  final DrawerNavigationMode navigationMode;
  final bool preventReloadIfSelected;

  const AppDrawerItem({
    required this.id,
    required this.title,
    required this.icon,
    this.preventReloadIfSelected = false,
    required this.routeName,
    this.requireLogin = false,
    this.navigationMode = DrawerNavigationMode.replace,
  });
}

class AppDrawerController extends ChangeNotifier {
  final AppController app;

  AppDrawerController({required this.app});

  String _selectedId = AppRoutes.sales;

  String get selectedId => _selectedId;

  // items (config central)
  late final List<AppDrawerItem> items = [
    AppDrawerItem(
      id: AppRoutes.salesKey,
      title: 'Punto de Venta',
      icon: Icons.shopping_basket_rounded,
      routeName: AppRoutes.sales,
      requireLogin: true,
      navigationMode: DrawerNavigationMode.restoreIfExists,
      preventReloadIfSelected: true,
    ),
    AppDrawerItem(
      id: AppRoutes.receiptsKey,
      title: 'Recibos',
      icon: Icons.receipt_long_rounded,
      routeName: AppRoutes.receipts,
      requireLogin: true,
      navigationMode: DrawerNavigationMode.push,
    ),
    AppDrawerItem(
      id: AppRoutes.shiftKey,
      title: 'Turno',
      icon: Icons.access_time_rounded,
      routeName: AppRoutes.shift,
      requireLogin: true,
      navigationMode: DrawerNavigationMode.push,
    ),
    AppDrawerItem(
      id: AppRoutes.itemsKey,
      title: 'Articulos',
      icon: Icons.format_list_bulleted_rounded,
      routeName: AppRoutes.items,
      requireLogin: true,
      navigationMode: DrawerNavigationMode.push,
    ),
    AppDrawerItem(
      id: AppRoutes.settingsKey,
      title: 'Settings & account',
      icon: Icons.settings,
      routeName: AppRoutes.settings,
      navigationMode: DrawerNavigationMode.push,
    ),
  ];

  void setSelectedByRoute(String route) {
    final found = items.where((i) => i.routeName == route).toList();
    if (found.isEmpty) return;
    _selectedId = found.first.id;
    notifyListeners();
  }

  /// ✅ Tap de item
  void onItemTap(BuildContext context, AppDrawerItem item) {
    if (item.requireLogin && !app.isLoggedIn) {
      Navigator.of(context).pop();
      Future.microtask(app.goToGate);
      return;
    }
    final routeCurrent = item.id;
    final isAlreadySelected = _selectedId == routeCurrent;
    if (!isAlreadySelected) {
      final isCurrentRoute = app.currentRouteName == item.routeName;

      if (item.preventReloadIfSelected &&
          (isAlreadySelected || isCurrentRoute)) {
        Navigator.of(context).pop();
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
          case DrawerNavigationMode.restoreIfExists:
            app.restoreRouteOrPush(item.routeName);
            break;
        }
      });
    }
  }

  void setSelected(String id) {
    _selectedId = id;
    notifyListeners();
  }
}
