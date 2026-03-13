import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/items/pos_items_layout.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/organisms/items/pos_items_content.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/point_sale/widgets/layouts/receipts/pos_receipts_layout.dart';
import '../../presentation/pages/point_sale/widgets/layouts/settings/pos_settings_layout.dart';
import '../../presentation/pages/point_sale_page.dart';
import '../app_gate.dart';
import 'package:flutter/material.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/point_sale/widgets/layouts/settings/pos_settings_layout.dart';
import '../../presentation/pages/point_sale_page.dart';
import '../app_gate.dart';

class AppRoutes {
  static const gate = '/gate';
  static const home = '/home';

  static const settings = '/settings';
  static const shift = '/shift';
  static const receipts = '/receipts';
  static const items = '/items';
  static const sales = '/sales';

  static const gateKey = 'gate';
  static const homeKey = 'home';
  static const settingsKey = 'settings';
  static const shiftKey = 'shift';
  static const receiptsKey = 'receipts';
  static const itemsKey = 'items';
  static const salesKey = 'sales';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.gate:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppGate(),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HomeScreenAllMenu(modules: const []),
        );
      case AppRoutes.sales:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PointSalePage(),
        );
      case AppRoutes.settings:
        final args = settings.arguments as PosSettingsLayoutArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosSettingsLayout(),
        );

      case AppRoutes.receipts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosReceiptsLayout(),
        );

      case AppRoutes.shift:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Shift Page'))),
        );
      case AppRoutes.items:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosItemsLayout(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppGate(),
        );
    }
  }
}

class PosSettingsLayoutArgs {
  final VoidCallback? onMenuTap;

  PosSettingsLayoutArgs({this.onMenuTap});
}
