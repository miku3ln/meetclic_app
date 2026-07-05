import 'package:flutter/material.dart';

import '../app_router.dart';
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
  void _syncRoute() {
    final route = app.currentRouteName;

    if (route == null) return;

    setSelectedByRoute(route);
  }
  AppDrawerController({
    required this.app,
  }) {
    app.addListener(_syncRoute);
  }
  @override
  void dispose() {
    app.removeListener(_syncRoute);
    super.dispose();
  }

  String _selectedId = AppRoutes.salesKey;

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
        navigationMode: DrawerNavigationMode.replace,
    ),
    AppDrawerItem(
      id: AppRoutes.shiftKey,
      title: 'Turno',
      icon: Icons.access_time_rounded,
      routeName: AppRoutes.shift,
      requireLogin: true,
        navigationMode: DrawerNavigationMode.replace,
    ),
    AppDrawerItem(
      id: AppRoutes.itemsKey,
      title: 'Articulos',
      icon: Icons.format_list_bulleted_rounded,
      routeName: AppRoutes.items,
      requireLogin: true,
        navigationMode: DrawerNavigationMode.replace,
    ),
    AppDrawerItem(
      id: AppRoutes.loyaltyKey,
      title: 'Fidelización',
      icon: Icons.favorite,
      routeName: AppRoutes.loyalty,
      requireLogin: true,
        navigationMode: DrawerNavigationMode.replace,
    ),
    AppDrawerItem(
      id: AppRoutes.settingsKey,
      title: 'Settings & account',
      icon: Icons.settings,
      requireLogin: true,
      routeName: AppRoutes.settings,
        navigationMode: DrawerNavigationMode.replace,
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
    final isSameSelected = _selectedId == item.id;
    final isSameRoute = app.currentRouteName == item.routeName;
    if (isSameSelected || isSameRoute) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop();
    Future.microtask(() {
      app.goToModule(item.routeName);
    });
  }

  void setSelected(String id) {
    _selectedId = id;
    notifyListeners();
  }
}
