import 'package:flutter/material.dart';

import '../../../infrastructure/assets/app_images.dart';
import '../../../shared/models/app_config.dart';
import '../../widgets/template/custom_app_bar/models/custom_app_bar_all_model.dart';

HeaderLayoutConfiguration buildInputWithThreeButtons({
  required TextEditingController searchController,
  required bool hasText,
  required ValueChanged<String> onSearch,
  required VoidCallback onOpenFilters,
  required VoidCallback onLanguage,

  required AppConfig config,
}) {
  final double space = 10;
  final String urlFlag = config.getUrlFlag();
  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.doubleColumnLeftWeighted,
    percentages: [0.60, 0.4],
    sections: [
      // 🟡 70% INPUT
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Buscar en MeetClic...",
            suffixIcon: IconButton(
              icon: Icon(
                Icons.search,
                // opcional: cambia color según haya texto o no
                color: hasText ? Colors.deepPurple : Colors.grey,
              ),
              // solo se activa si hay texto
              onPressed: hasText
                  ? () => onSearch(searchController.text.trim())
                  : null,
            ),
          ),
          textInputAction: TextInputAction.search,
          // 👇 eventos:
          onTap: () {
            // click/tap en el input
            print('Tap en el buscador');
          },
          onChanged: (value) {
            // cambia el texto mientras escribe
            print('Buscando: $value');
            // aquí puedes disparar un filtro en tiempo real
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              onSearch(value.trim());
            }
            // aquí lanzas la búsqueda final
          },
        ),
        // botón de buscar en el teclado
      ),

      // 🔵 30% BOTONES
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onOpenFilters,
              child: Icon(Icons.tune, size: 26),
            ),
            SizedBox(width: space),
            GestureDetector(
              onTap: () => {onLanguage()},
              child: Image.asset(urlFlag, width: 26, height: 26),
            ),
            SizedBox(width: space),
            GestureDetector(
              onTap: () => print("gamificación"),
              child: Image.asset(
                AppImages.rewardTypeTrophy,
                width: 26,
                height: 26,
              ),
            ),
            SizedBox(width: space),
            GestureDetector(
              onTap: () => {print("ventas")},
              child: Icon(Icons.storefront_rounded, size: 26),
            ),
            SizedBox(width: space),
          ],
        ),
      ),
    ],
  );
}

HeaderLayoutConfiguration buildRightImageWithThreeButtons({
  required Widget imageWidget,
  required VoidCallback onFirstPressed,
  required VoidCallback onSecondPressed,
  required VoidCallback onThirdPressed,
}) {
  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.doubleColumnRightWeighted,
    percentages: [0.25, 0.75], // o [0.30, 0.70] si quieres 70/30
    sections: [
      // 🟡 25% IMAGEN
      HeaderSectionModel(
        type: HeaderSectionType.imageIcon,
        content: Align(alignment: Alignment.centerLeft, child: imageWidget),
      ),

      // 🔵 75% BUTTONS (3 botones)
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: onFirstPressed,
            ),
            IconButton(
              icon: Image.asset(
                AppImages.rewardTypeTrophy,
                width: 24,
                height: 24,
              ),
              onPressed: onSecondPressed,
            ),
            IconButton(
              icon: const Icon(Icons.storefront_rounded),
              onPressed: onThirdPressed,
            ),
          ],
        ),
      ),
    ],
  );
}
