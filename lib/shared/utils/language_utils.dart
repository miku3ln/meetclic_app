import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';
import 'package:meetclic_app/presentation/pages/home/modals/language_modal.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/models/language_modal_config.dart';

Map<String, String> getLanguageMap(BuildContext context) {
  return {
    'es': AppLocalizations.of(context).translate('language.spanish'),
    'en': AppLocalizations.of(context).translate('language.english'),
    'it': AppLocalizations.of(context).translate('language.kichwa'),
  };
}

Map<String, String> getFlagMap() {
  return {
    'es': AppImages.flagLanguageEs,
    'en': AppImages.flagLanguageEn,
    'it': AppImages.flagLanguageKi,
  };
}

void updateMenuItem({
  required LanguageModalConfig config,
  required String selectedLangCode,
  required Map<String, String> flags,
  required VoidCallback onClose,
}) {
  final newFlag = flags[selectedLangCode]!;

  final menuItemIdiomaActualizado = MenuTabUpItem(
    id: 1,
    name: 'idioma',
    asset: newFlag,
    number: 3,
    onTap: () => showTopLanguageModal(config),
  );

  config.setStateFn(() {
    config.menuTabUpItems[0] = menuItemIdiomaActualizado;
  });

  onClose();
}
