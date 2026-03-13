import 'package:flutter/material.dart';
import '../../presentation/pages/home/home_page.dart';
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
        return MaterialPageRoute(builder: (_) => const AppGate());
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomeScreenAllMenu(modules: const []),
        );
      case AppRoutes.sales:
        return MaterialPageRoute(builder: (_) => const PointSalePage());
      case AppRoutes.settings:
        final args = settings.arguments as PosSettingsLayoutArgs?;
        return MaterialPageRoute(builder: (_) => PosSettingsLayout());

      case AppRoutes.receipts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Receipts Page')),
          ),
        );

      case AppRoutes.shift:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Shift Page')),
          ),
        );

      case AppRoutes.items:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Items Page')),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const AppGate());
    }
  }
}

class PosSettingsLayoutArgs {
  final VoidCallback? onMenuTap;

  PosSettingsLayoutArgs({this.onMenuTap});
}
