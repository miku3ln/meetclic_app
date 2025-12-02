import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (locale) {
        context.setLocale(locale); // ✅ cambia idioma dinámicamente
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('es'),
          child: Text('Español'),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Text('English'),
        ),
        PopupMenuItem(
          value: const Locale('it'),
          child: Text('Kichwa'),
        ),
      ],
    );
  }
}
