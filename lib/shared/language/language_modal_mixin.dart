import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/shared/models/app_config.dart';

import '../../presentation/pages/home/modals/language_modal.dart';
import '../models/language_modal_config.dart';

// ↑ ajusta imports según dónde tengas showTopLanguageModal / LanguageModalConfig

mixin LanguageModalMixin<T extends StatefulWidget> on State<T> {
  /// Llama al modal de idiomas con la lógica estándar
  void showLanguageModal({
    required AppConfig config,
    List<MenuTabUpItem> menuTabUpItems = const [],
  }) {
    showTopLanguageModal(
      LanguageModalConfig(
        context: context,
        onChanged: (newLocale) => config.setLocale(Locale(newLocale)),
        menuTabUpItems: menuTabUpItems,
        setStateFn: _onFlagChanged,
      ),
    );
  }

  /// Wrapper de setState que acepta una función y la ejecuta dentro de setState
  void _onFlagChanged(VoidCallback fn) {
    setState(() {
      fn();
    });
  }
}
