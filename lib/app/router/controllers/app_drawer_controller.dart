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

  // NUEVO
  final List<AppDrawerItem> children;

  const AppDrawerItem({
    required this.id,
    required this.title,
    required this.icon,
    this.preventReloadIfSelected = false,
    required this.routeName,
    this.requireLogin = false,
    this.navigationMode = DrawerNavigationMode.replace,
    this.children = const [],
  });
  bool get hasChildren => children.isNotEmpty;
}

class AppDrawerController extends ChangeNotifier {
  final AppController app;
  final Set<String> _expandedIds = {};
  bool isExpanded(String id) {
    return _expandedIds.contains(id);
  }
  void toggleExpanded(String id) {
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }

    notifyListeners();
  }
  void setExpanded(
      String id,
      bool expanded,
      ) {
    if (expanded) {
      _expandedIds.add(id);
    } else {
      _expandedIds.remove(id);
    }

    notifyListeners();
  }
  AppDrawerItem? _findParentOfRoute(
      List<AppDrawerItem> items,
      String route,
      ) {
    for (final item in items) {
      for (final child in item.children) {
        if (child.routeName == route) {
          return item;
        }

        final parent = _findParentOfRoute(
          child.children,
          route,
        );

        if (parent != null) {
          return parent;
        }
      }
    }

    return null;
  }
  void _syncRoute2() {
    final route = app.currentRouteName;

    if (route == null) return;

    // 🔥 SIEMPRE sincroniza correctamente
    final match = items.where((i) => i.routeName == route).toList();

    if (match.isEmpty) {
      // fallback seguro → SALES
      _selectedId = AppRoutes.salesKey;
    } else {
      _selectedId = match.first.id;
    }
    notifyListeners();
  }
  void _syncRoute() {
    final route = app.currentRouteName;

    if (route == null) return;

    // Buscar item principal
    final match = items.where(
          (item) => item.routeName == route,
    );

    if (match.isNotEmpty) {
      _selectedId = match.first.id;
    } else {
      _selectedId = AppRoutes.salesKey;
    }

    // Buscar padre del hijo actual
    final parent = _findParentOfRoute(
      items,
      route,
    );

    if (parent != null) {
      _expandedIds.add(parent.id);
      _selectedId = parent.id;
    }

    notifyListeners();
  }
  AppDrawerController({required this.app}) {
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
      children: [
        AppDrawerItem(
          id: AppRoutes.itemsKey,
          title: 'Productos',
          icon: Icons.inventory_2_outlined,
          routeName: AppRoutes.items,
          requireLogin: true,
        ),

        AppDrawerItem(
          id: 'categories',
          title: 'Categorías',
          icon: Icons.category_outlined,
          routeName: AppRoutes.categories,
          requireLogin: true,
        ),

        AppDrawerItem(
          id: 'subcategories',
          title: 'Subcategorias',
          icon: Icons.warehouse_outlined,
          routeName: AppRoutes.subCategories,
          requireLogin: true,
        ),
      ],
    ),
    AppDrawerItem(
      id: AppRoutes.loyaltyKey,
      title: 'Fidelización',
      icon: Icons.favorite,
      routeName: AppRoutes.loyalty,
      requireLogin: true,
      navigationMode: DrawerNavigationMode.replace,
      children: [
        AppDrawerItem(
          id: AppRoutes.dashboardKey,
          title: 'Dashboard',
          icon: Icons.format_list_bulleted,
          routeName: AppRoutes.dashboard,
          requireLogin: true,
        ),

        AppDrawerItem(
          id: AppRoutes.cuponKey,
          title: 'Cupones',
          icon: Icons.copy_rounded,
          routeName: AppRoutes.cupon,
          requireLogin: true,
        ),

        AppDrawerItem(
          id: AppRoutes.gamificationKey,
          title: 'Gamificacion',
          icon: Icons.note_alt_outlined,
          routeName: AppRoutes.gamification,
          requireLogin: true,
        ),
        AppDrawerItem(
          id: AppRoutes.trackingKey,
          title: 'Canales',
          icon: Icons.local_offer_outlined,
          routeName: AppRoutes.tracking,
          requireLogin: true,
        ),
      ],

    ),
    AppDrawerItem(
      id: AppRoutes.settingsKey,
      title: 'Settings & account',
      icon: Icons.settings,
      requireLogin: true,
      routeName: AppRoutes.settings,
      navigationMode: DrawerNavigationMode.replace,
      children: [
        AppDrawerItem(
          id: AppRoutes.printersKey,
          title: 'Impresoras',
          icon: Icons.print,
          routeName: AppRoutes.printers,
          requireLogin: true,
        ),

        AppDrawerItem(
          id: AppRoutes.customerScreenKey,
          title: 'Pantalla para clientes',
          icon: Icons.desktop_windows,
          routeName: AppRoutes.customerScreen,
          requireLogin: true,
        ),

        AppDrawerItem(
          id: AppRoutes.taxesKey,
          title: 'Impuestos',
          icon: Icons.percent,
          routeName: AppRoutes.taxes,
          requireLogin: true,
        ),
        AppDrawerItem(
          id: AppRoutes.generalKey,
          title: 'General',
          icon: Icons.settings,
          routeName: AppRoutes.general,
          requireLogin: true,
        ),
      ],
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
