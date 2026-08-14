import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/items/pos_items_layout.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/organisms/items/pos_items_content.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/point_sale/state/pos_items_controller.dart';
import '../../presentation/pages/point_sale/state/pos_loyalty_controller.dart';
import '../../presentation/pages/point_sale/state/pos_settings_controller.dart';
import '../../presentation/pages/point_sale/widgets/layouts/loyalty/pos_loyalty_layout.dart';
import '../../presentation/pages/point_sale/widgets/layouts/receipts/pos_receipts_layout.dart';
import '../../presentation/pages/point_sale/widgets/layouts/settings/pos_settings_layout.dart';
import '../../presentation/pages/point_sale/widgets/layouts/shift/pos_shift_layout.dart';
import '../../presentation/pages/point_sale_page.dart';
import '../../shared/providers_session.dart';
import '../app_gate.dart';
import 'package:flutter/material.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/point_sale/widgets/layouts/settings/pos_settings_layout.dart';
import '../../presentation/pages/point_sale_page.dart';
import '../app_gate.dart';

class AppRoutes {
  static const gate = '/gate';
  static const home = '/home';

  static const shift = '/shift';
  static const receipts = '/receipts';

  static const sales = '/sales';

  static const gateKey = 'gate';
  static const homeKey = 'home';

  static const shiftKey = 'shift';
  static const receiptsKey = 'receipts';
  static const salesKey = 'sales';

  //Articulos
  static const itemsKey = 'items';
  static const items = '/items';

  static const categories = '/categories';
  static const categoriesKey = 'categories';

  static const subCategories = '/subCategories';
  static const subCategoriesKey = 'subCategories';

  //FIDELIZACION
  static const loyalty = '/loyalty';
  static const loyaltyKey = 'loyalty';
  static const dashboard = '/dashboard';
  static const dashboardKey = 'dashboard';

  static const cupon = '/cupon';
  static const cuponKey = 'cuponKey';

  static const gamification = '/gamification';
  static const gamificationKey = 'gamification';

  static const tracking = '/tracking';
  static const trackingKey = 'tracking';

  //CONFIGURATION
  static const settingsKey = 'settings';
  static const settings = '/settings';

  static const generalKey = 'general';
  static const general = '/general';

  static const taxesKey = 'taxes';
  static const taxes = '/taxes';

  static const customerScreenKey = 'customerScreen';
  static const customerScreen = '/customerScreen';

  static const printersKey = 'printers';
  static const printers = '/printers';
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
          builder: (_) => const PointSaleScope(),
        );
      case AppRoutes.settings:
        final args = settings.arguments as PosSettingsLayoutArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              PosSettingsLayout(section: PosSettingsSection.printers),
        );
      case AppRoutes.taxes:
        final args = settings.arguments as PosSettingsLayoutArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosSettingsLayout(section: PosSettingsSection.taxes),
        );
      case AppRoutes.customerScreen:
        final args = settings.arguments as PosSettingsLayoutArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              PosSettingsLayout(section: PosSettingsSection.customerScreen),
        );
      case AppRoutes.printers:
        final args = settings.arguments as PosSettingsLayoutArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              PosSettingsLayout(section: PosSettingsSection.printers),
        );
      case AppRoutes.general:
        final args = settings.arguments as PosSettingsLayoutArgs?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              PosSettingsLayout(section: PosSettingsSection.general),
        );
      case AppRoutes.receipts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosReceiptsLayout(),
        );

      case AppRoutes.shift:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosShiftManagementLayout(),
        );
      case AppRoutes.items:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosItemsLayout(section: PosItemsSection.items),
        );

      case AppRoutes.categories:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosItemsLayout(section: PosItemsSection.categories),
        );
      case AppRoutes.subCategories:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              PosItemsLayout(section: PosItemsSection.subcategories),
        );

      case AppRoutes.loyalty:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              PosLoyaltyLayout(section: PosLoyaltySection.dashboard),
        );

      case AppRoutes.cupon:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosLoyaltyLayout(section: PosLoyaltySection.cupon),
        );

      case AppRoutes.gamification:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              PosLoyaltyLayout(section: PosLoyaltySection.gamification),
        );
      case AppRoutes.tracking:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PosLoyaltyLayout(section: PosLoyaltySection.tracking),
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
