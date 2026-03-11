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
  static const pos = '/pos';
  static const settings = '/settings';
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

      case AppRoutes.pos:
        return MaterialPageRoute(
          builder: (_) => const PointSalePage(),
        );

      case AppRoutes.settings:
        final args = settings.arguments as PosSettingsLayoutArgs?;
        return MaterialPageRoute(
          builder: (_) => PosSettingsLayout(

          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const AppGate());
    }
  }
}
class PosSettingsLayoutArgs {
  final VoidCallback? onMenuTap;

  PosSettingsLayoutArgs({
    this.onMenuTap,
  });
}