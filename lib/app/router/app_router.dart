import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/items/pos_items_layout.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/point_sale/state/pos_items_controller.dart';
import '../../presentation/pages/point_sale/state/pos_loyalty_controller.dart';
import '../../presentation/pages/point_sale/state/pos_settings_controller.dart';
import '../../presentation/pages/point_sale/widgets/layouts/business_manager/business_manager.dart';
import '../../presentation/pages/point_sale/widgets/layouts/loyalty/pos_loyalty_layout.dart';
import '../../presentation/pages/point_sale/widgets/layouts/pos_main_controller.dart';
import '../../presentation/pages/point_sale/widgets/layouts/receipts/pos_receipts_layout.dart';
import '../../presentation/pages/point_sale/widgets/layouts/settings/pos_settings_layout.dart';
import '../../presentation/pages/point_sale/widgets/layouts/shift/pos_shift_layout.dart';
import '../../presentation/pages/point_sale_page.dart';
import '../../shared/providers_session.dart';
import '../app_gate.dart';
import 'package:provider/provider.dart';

import 'controllers/app_controller.dart';

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

  static const businessManager = '/businessManager';
  static const businessManagerKey = 'businessManager';

  // =========================
  // ARTÍCULOS
  // =========================
  static const items = '/items';
  static const itemsKey = 'items';

  // NUEVO: ID exclusivo del child
  static const productsKey = 'products';

  static const categories = '/categories';
  static const categoriesKey = 'categories';

  static const subCategories = '/subCategories';
  static const subCategoriesKey = 'subCategories';

  // =========================
  // FIDELIZACIÓN
  // =========================
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

  // =========================
  // CONFIGURATION
  // =========================
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

  static Widget _withPosMainController({
    required BuildContext context,
    required Widget child,
  }) {
    final app = context.read<AppController>();

    final PosMainController? main =
        app.posMainController;

    if (main == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No existe una instancia activa de PosMainController.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ChangeNotifierProvider<PosMainController>.value(
      value: main,
      child: child,
    );
  }

  static Route<dynamic> onGenerateRoute(
      RouteSettings settings,
      ) {
    switch (settings.name) {
    /**
     * ============================================================
     * APP
     * ============================================================
     */

      case AppRoutes.gate:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AppGate(),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              HomeScreenAllMenu(modules: const []),
        );

    /**
     * ============================================================
     * POS PRINCIPAL
     *
     * Esta ruta CREA PosMainController.
     * NO usar _withPosMainController aquí.
     * ============================================================
     */

      case AppRoutes.sales:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PointSaleScope(),
        );

    /**
     * ============================================================
     * BUSINESS
     * ============================================================
     */

      case AppRoutes.businessManager:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child:
              const BusinessManagerManagementLayout(),
            );
          },
        );

    /**
     * ============================================================
     * SHIFT
     * ============================================================
     */

      case AppRoutes.shift:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child:
              const PosShiftManagementLayout(),
            );
          },
        );

    /**
     * ============================================================
     * RECEIPTS
     * ============================================================
     */

      case AppRoutes.receipts:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosReceiptsLayout(),
            );
          },
        );

    /**
     * ============================================================
     * ITEMS
     * ============================================================
     */

      case AppRoutes.items:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosItemsLayout(
                section: PosItemsSection.items,
              ),
            );
          },
        );

      case AppRoutes.categories:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosItemsLayout(
                section:
                PosItemsSection.categories,
              ),
            );
          },
        );

      case AppRoutes.subCategories:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosItemsLayout(
                section:
                PosItemsSection.subcategories,
              ),
            );
          },
        );

    /**
     * ============================================================
     * LOYALTY
     * ============================================================
     */

      case AppRoutes.loyalty:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosLoyaltyLayout(
                section:
                PosLoyaltySection.dashboard,
              ),
            );
          },
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosLoyaltyLayout(
                section:
                PosLoyaltySection.dashboard,
              ),
            );
          },
        );

      case AppRoutes.cupon:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosLoyaltyLayout(
                section:
                PosLoyaltySection.cupon,
              ),
            );
          },
        );

      case AppRoutes.gamification:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosLoyaltyLayout(
                section:
                PosLoyaltySection.gamification,
              ),
            );
          },
        );

      case AppRoutes.tracking:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosLoyaltyLayout(
                section:
                PosLoyaltySection.tracking,
              ),
            );
          },
        );

    /**
     * ============================================================
     * SETTINGS
     * ============================================================
     */

      case AppRoutes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosSettingsLayout(
                section:
                PosSettingsSection.printers,
              ),
            );
          },
        );

      case AppRoutes.general:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosSettingsLayout(
                section:
                PosSettingsSection.general,
              ),
            );
          },
        );

      case AppRoutes.taxes:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosSettingsLayout(
                section:
                PosSettingsSection.taxes,
              ),
            );
          },
        );

      case AppRoutes.customerScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosSettingsLayout(
                section:
                PosSettingsSection.customerScreen,
              ),
            );
          },
        );

      case AppRoutes.printers:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return _withPosMainController(
              context: context,
              child: PosSettingsLayout(
                section:
                PosSettingsSection.printers,
              ),
            );
          },
        );

    /**
     * ============================================================
     * DEFAULT
     * ============================================================
     */

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
