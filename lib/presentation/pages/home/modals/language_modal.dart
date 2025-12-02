import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/home/modals/language_modal_widgets.dart';
import 'package:meetclic_app/shared/models/app_config.dart';
import 'package:meetclic_app/shared/models/language_modal_config.dart'; // nuevo import
import 'package:meetclic_app/shared/utils/language_utils.dart';
import 'package:provider/provider.dart';

void showTopLanguageModal(LanguageModalConfig configData) {
  final context = configData.context;
  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;
  final modalHeight = screenSize.height * 0.3;
  final config = Provider.of<AppConfig>(context, listen: false);
  final currentLocale = config.locale.languageCode;

  final languages = getLanguageMap(context);
  final flags = getFlagMap();

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Stack(
      children: [
        buildBackdrop(() {
          if (entry.mounted) entry.remove();
        }, screenSize),
        buildLanguageModal(
          context: context,
          screenSize: screenSize,
          modalHeight: modalHeight,
          currentLocale: currentLocale,
          languages: languages,
          flags: flags,
          onChanged: (code) {
            if (entry.mounted) entry.remove(); // cierra primero
            configData.onChanged(code);
            updateMenuItem(
              config: configData,
              selectedLangCode: code,
              flags: flags,
              onClose: () {}, // ya cerrado
            );
          },
        ),
      ],
    ),
  );

  overlay.insert(entry);
}
