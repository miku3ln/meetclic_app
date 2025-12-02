import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';

/// Fondo semitransparente detrás del modal
Widget buildBackdrop(VoidCallback onTap, Size screenSize) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: screenSize.width,
      height: screenSize.height,
      color: Colors.black.withOpacity(0.4),
    ),
  );
}

/// Modal superior para seleccionar idioma
Widget buildLanguageModal({
  required BuildContext context,
  required Size screenSize,
  required double modalHeight,
  required String currentLocale,
  required Map<String, String> languages,
  required Map<String, String> flags,
  required Function(String) onChanged,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Positioned(
    top: 73,
    left: 0,
    right: 0,
    child: Material(
      color: Colors.transparent,
      child: StatefulBuilder(
        builder: (context, setState) {
          // ✅ Mutable local state
          String selectedLocale = currentLocale;

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                width: screenSize.width,
                height: modalHeight,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('language.select'),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: languages.entries.map((entry) {
                          return buildLanguageOption(
                            context: context,
                            langCode: entry.key,
                            label: entry.value,
                            currentLocale:
                                selectedLocale, // ✅ usa variable local mutable
                            flagPath: flags[entry.key]!,
                            onTap: () {
                              // ✅ Cambia idioma global
                              onChanged(entry.key);

                              // ✅ Actualiza selección visual local
                              setState(() {
                                selectedLocale = entry.key;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Widget buildLanguageOption({
  required BuildContext context,
  required String langCode,
  required String label,
  required String currentLocale,
  required String flagPath,
  required VoidCallback onTap,
}) {
  final isSelected = langCode == currentLocale;
  final colorScheme = Theme.of(context).colorScheme;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 3)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(flagPath, width: 50, height: 35, fit: BoxFit.contain),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    ),
  );
}
