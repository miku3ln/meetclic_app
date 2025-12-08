import 'package:flutter/material.dart';
import 'package:meetclic_app/aplication/services/access_manager_service.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';
import 'package:meetclic_app/presentation/pages/home/modals/language_modal.dart';
import 'package:meetclic_app/presentation/pages/home/modals/show_view_components.dart';
import 'package:meetclic_app/shared/models/app_config.dart';
import 'package:meetclic_app/shared/models/language_modal_config.dart';
import 'package:meetclic_app/shared/providers_session.dart';

class MenuTabUpController {
  /// Construye la lista de items del menú superior (bandera + contadores).
  static List<MenuTabUpItem> buildMenu({
    required BuildContext context,
    required AppConfig config,
    required void Function(void Function()) setFlagCallback,
    required SessionService session,
  }) {
    final accessManager = AccessManagerService(context);
    final user = session.currentSession;

    final double yapitas = session.isLoggedIn
        ? user?.summary?.yapitas.currentBalance ?? 0
        : 0;

    final double yapitasPremium = session.isLoggedIn
        ? user?.summary?.yapitasPremium.currentBalance ?? 0
        : 0;

    final double trofeos = session.isLoggedIn
        ? user?.summary?.trophies.total ?? 0
        : 0;

    final double cesta = 0;
    final double idioma = 3;

    // Normalizamos el código de idioma (por si quedó 'it' viejo)
    final rawLocale = config.locale.languageCode; // 'es', 'en', 'ki', etc.
    final locale = rawLocale != 'it' ? rawLocale : 'ki';

    // Esta es la lista REAL que se usará en el AppBar
    final List<MenuTabUpItem> items = [];

    // Item de idioma (bandera)
    final itemLanguage = MenuTabUpItem(
      id: 1,
      name: 'idioma',
      asset: 'assets/flags/$locale.png',
      number: idioma,
      onTap: () => showTopLanguageModal(
        LanguageModalConfig(
          context: context,
          onChanged: (newLocale) => config.setLocale(Locale(newLocale)),
          menuTabUpItems: items, // 👉 referencia a la MISMA lista
          setStateFn: setFlagCallback, // 👉 setState de HomeMainMenu
        ),
      ),
    );

    items.addAll([
      itemLanguage,
      _item(
        context,
        'trofeo',
        AppImages.rewardTypeReputation,
        trofeos,
        accessManager,
      ),
      _item(
        context,
        'fuego',
        AppImages.coinTypeYapitas,
        yapitas,
        accessManager,
      ),
      _item(
        context,
        'diamante',
        AppImages.coinTypeYapitasPremium,
        yapitasPremium,
        accessManager,
      ),
      _item(context, 'cesta', AppImages.basketEcommerce, cesta, accessManager),
    ]);

    return items;
  }

  /// Helper para crear los demás items (trofeo, fuego, diamante, cesta).
  static MenuTabUpItem _item(
    BuildContext context,
    String name,
    String asset,
    double count,
    AccessManagerService accessManager,
  ) {
    return MenuTabUpItem(
      id: name.hashCode,
      name: name,
      asset: asset,
      number: count,
      onTap: () async {
        final result = await accessManager.handleAccess(() async {
          showViewComponents(context, (formData) {
            // Aquí luego conectas con lo que necesites
            print('🚀 Datos recibidos: $formData');
          });
        });

        if (result.success) {
          print('✅ Acceso concedido o registrado ($name)');
        } else {
          print('❌ Error: ${result.message} ($name)');
        }
      },
    );
  }
}
