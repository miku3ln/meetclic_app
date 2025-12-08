import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import 'package:meetclic_app/shared/utils/deep_link_type.dart';

import 'home_tab_id.dart';

/// Define cómo es un tab del Home:
/// - id lógico
/// - cuándo es visible
/// - cómo construye su widget
/// - cómo se ve en el BottomNavigationBar
class HomeTabDefinition {
  final HomeTabId id;

  /// Regla de visibilidad según la sesión.
  final bool Function(SessionService session) isVisible;

  /// Builder de la pantalla del tab.
  ///
  /// Recibe:
  /// - session: sesión actual
  /// - menuItems: items del menú superior
  /// - pendingDeepLink: deep link pendiente (si aplica)
  /// - l10n: localización actual
  final Widget Function(
    SessionService session,
    List<MenuTabUpItem> menuItems,
    DeepLinkInfo? pendingDeepLink,
    AppLocalizations l10n,
  )
  builder;

  /// Builder del item del BottomNavigationBar.
  final BottomNavigationBarItem Function(AppLocalizations l10n) navItemBuilder;

  const HomeTabDefinition({
    required this.id,
    required this.isVisible,
    required this.builder,
    required this.navItemBuilder,
  });
}
