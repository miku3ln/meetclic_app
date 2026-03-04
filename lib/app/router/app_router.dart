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
  static Map<String, WidgetBuilder> routes() => {
    AppRoutes.gate: (_) => const AppGate(),
    AppRoutes.home: (_) => HomeScreenAllMenu(modules: const []),
    AppRoutes.pos: (_) => const PointSalePage(),
    AppRoutes.settings: (_) => const PosSettingsLayout(), // ✅ AQUI


  };
}