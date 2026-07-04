import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/domain/services/session_service.dart';
import 'package:meetclic_app/presentation/pages/business_map_page.dart';
import 'package:meetclic_app/presentation/pages/point_sale_page.dart';
import 'package:meetclic_app/presentation/pages/profile_page.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import 'package:meetclic_app/shared/utils/deep_link_type.dart';

import '../../../gamification_page.dart';
import '../../../more_page.dart';
import '../../../store_page.dart';
import '../models/home_tab_definition.dart';
import '../models/home_tab_id.dart';
// Átomo para construir items del BottomNavigationBar
import '../widgets/atoms/home_nav_item_atom.dart';

class HomeTabFactory {
  /// Construye la lista de tabs disponibles para el Home.
  ///
  /// Aquí defines:
  /// - Qué tabs existen
  /// - Cuándo son visibles
  /// - Qué widget construyen
  /// - Cómo se ven en el BottomNavigationBar
  static List<HomeTabDefinition> buildTabs({
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    return [
      HomeTabDefinition(
        id: HomeTabId.pointSale,
        isVisible: (_) => true,
        builder:
            (
            SessionService session,
            List<MenuTabUpItem> menuItems,
            DeepLinkInfo? pendingDeepLink,
            AppLocalizations localL10n,
            ) {
          final theme = Theme.of(context);
          final title = localL10n.translate('pages.home');
          /*return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: CustomAppBar(title: title, items: menuItems),
                body: const HomeScrollView(),
              );*/

          return PointSaleScope();
        },
        navItemBuilder: (localL10n) => HomeNavItemAtom.build(
          icon: Icons.home,
          label: localL10n.translate('pages.home'),
        ),
      ),

      // =========================================================
      // 🏠 TAB: HOME
      // =========================================================
      HomeTabDefinition(
        id: HomeTabId.home,
        isVisible: (_) => true,
        builder:
            (
              SessionService session,
              List<MenuTabUpItem> menuItems,
              DeepLinkInfo? pendingDeepLink,
              AppLocalizations localL10n,
            ) {
              final theme = Theme.of(context);
              final title = localL10n.translate('pages.home');
              /*return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: CustomAppBar(title: title, items: menuItems),
                body: const HomeScrollView(),
              );*/

              return GamificationPage(title: "", itemsStatus: menuItems);
            },
        navItemBuilder: (localL10n) => HomeNavItemAtom.build(
          icon: Icons.home,
          label: localL10n.translate('pages.home'),
        ),
      ),

      // =========================================================
      // 🌍 TAB: EXPLORE (MAPA DE NEGOCIOS)
      // =========================================================
      HomeTabDefinition(
        id: HomeTabId.explore,
        isVisible: (_) => true,
        builder:
            (
              SessionService session,
              List<MenuTabUpItem> menuItems,
              DeepLinkInfo? pendingDeepLink,
              AppLocalizations localL10n,
            ) {
              // pendingDeepLink se pasa al BusinessMapPage (por ejemplo, para abrir un negocio específico)
              return BusinessMapPage(
                info: pendingDeepLink,
                itemsStatus: menuItems,
              );
            },
        navItemBuilder: (localL10n) => HomeNavItemAtom.build(
          icon: Icons.language,
          label: localL10n.translate('pages.explore'),
        ),
      ),

      // =========================================================
      // 👤 TAB: PROFILE (solo si está logueado)
      // =========================================================
      HomeTabDefinition(
        id: HomeTabId.profile,
        isVisible: (SessionService session) => session.isLoggedIn,
        builder:
            (
              SessionService session,
              List<MenuTabUpItem> menuItems,
              DeepLinkInfo? pendingDeepLink,
              AppLocalizations localL10n,
            ) {
              final title = localL10n.translate('pages.profile');
              return ProfilePage(
                title: title,
                itemsStatus: menuItems,
                session: session,
              );
            },
        navItemBuilder: (localL10n) => HomeNavItemAtom.build(
          icon: Icons.person,
          label: localL10n.translate('pages.profile'),
        ),
      ),
      // =========================================================
      // 🎮 TAB: GAMING (RIVE / JUEGOS)
      // =========================================================
      HomeTabDefinition(
        id: HomeTabId.shop,
        isVisible: (SessionService session) => session.isLoggedIn,
        builder:
            (
              SessionService session,
              List<MenuTabUpItem> menuItems,
              DeepLinkInfo? pendingDeepLink,
              AppLocalizations localL10n,
            ) {
              final title = localL10n.translate('pages.shop');
              return StorePage(title: title, itemsStatus: menuItems);
            },
        navItemBuilder: (localL10n) => HomeNavItemAtom.build(
          icon: Icons.storefront_rounded,
          label: localL10n.translate('pages.shop'),
        ),
      ),

      HomeTabDefinition(
        id: HomeTabId.more,
        isVisible: (_) => true,
        builder:
            (
              SessionService session,
              List<MenuTabUpItem> menuItems,
              DeepLinkInfo? pendingDeepLink,
              AppLocalizations localL10n,
            ) {
              final title = localL10n.translate('pages.more');
              return MorePage(title: title, itemsStatus: menuItems);
            },
        navItemBuilder: (localL10n) => HomeNavItemAtom.build(
          icon: Icons.more_horiz,
          label: localL10n.translate('pages.more'),
        ),
      ),
    ];
  }
}
