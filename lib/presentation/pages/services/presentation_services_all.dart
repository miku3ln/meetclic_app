import 'package:flutter/material.dart';

import '../../../infrastructure/assets/app_images.dart';
import '../../../shared/models/app_config.dart';
import '../../../shared/themes/app_colors.dart';
import '../../widgets/template/custom_app_bar.dart';
import '../../widgets/template/custom_app_bar/models/custom_app_bar_all_model.dart';

HeaderLayoutConfiguration buildTitleWithThreeButtons({
  required String title,
  required VoidCallback onOpenFilters,
  required VoidCallback onLanguage,
  required AppConfig config,
  Color? titleColor,
  double titleFontSize = 18,
  FontWeight titleFontWeight = FontWeight.w600,
}) {
  final double space = 10;
  final String urlFlag = config.getUrlFlag();

  // Color por defecto desde MeetClic (ejemplo usando AppColors)
  final Color resolvedTitleColor = titleColor ?? AppColors.azulClic;
  // Cambia AppColors.primary por azulClic o el que tengas definido

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.doubleColumnLeftWeighted,
    percentages: const [0.60, 0.40],
    sections: [
      // 🟡 60% TEXTO (no input)
      HeaderSectionModel(
        type: HeaderSectionType.textInput, // podemos seguir usando este tipo
        content: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: resolvedTitleColor,
              fontSize: titleFontSize,
              fontWeight: titleFontWeight,
            ),
          ),
        ),
      ),

      // 🔵 40% BOTONES
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onOpenFilters,
              child: const Icon(Icons.tune, size: 26),
            ),
            SizedBox(width: space),
            GestureDetector(
              onTap: onLanguage,
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
              onTap: () => print("ventas"),
              child: const Icon(Icons.storefront_rounded, size: 26),
            ),
            SizedBox(width: space),
          ],
        ),
      ),
    ],
  );
}

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

HeaderLayoutConfiguration buildMeetclicHeader({
  required bool isSearching,
  required TextEditingController controller,
  required FocusNode focusNode,
  required HeaderSearchBehavior behavior,
  required VoidCallback onSearch,
  required VoidCallback onBack,
  required VoidCallback onLanguage,
  required VoidCallback onFilters,
  required AppConfig config,
}) {
  const double space = 10;
  final urlFlag = config.getUrlFlag();

  // ⏳ TÍTULO NORMAL
  final title = Text(
    'Meetclic',
    style: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.azulClic,
    ),
  );

  // 🔍 INPUT SEARCH
  final searchInput = TextField(
    controller: controller,
    focusNode: focusNode,
    decoration: const InputDecoration(
      hintText: 'Buscar…',
      border: InputBorder.none,
    ),
  );

  // 🎛 BOTONES NORMALES
  final normalButtons = Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      GestureDetector(onTap: onFilters, child: const Icon(Icons.tune)),
      const SizedBox(width: space),
      GestureDetector(
        onTap: onLanguage,
        child: Image.asset(urlFlag, width: 26),
      ),
      const SizedBox(width: space),
      GestureDetector(onTap: onSearch, child: const Icon(Icons.search)),
    ],
  );

  // ⬅️ BACK BUTTON
  final backButton = GestureDetector(
    onTap: onBack,
    child: const Icon(Icons.arrow_back, size: 26),
  );

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: const [0.20, 0.50, 0.30],
    sections: [
      // ====== IZQUIERDA =======
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        visible: isSearching && behavior.showBackButton,
        content: backButton,
      ),

      // ====== CENTRO =======
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        visible: !isSearching || !behavior.hideCenterContent,
        content: isSearching && behavior.showSearchInput ? searchInput : title,
      ),

      // ====== DERECHA =======
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        visible: !isSearching || !behavior.hideRightButtons,
        content: normalButtons,
      ),
    ],
  );
}

HeaderLayoutConfiguration buildSearchHeaderLayout({
  required SearchHeaderContext ctx,
  required AppConfig config,
  required List<HeaderActionItem> rightActions,
  HeaderSearchVisualConfig searchStyle = HeaderSearchVisualConfig.defaults,
  required final ValueChanged<String>? onChangedSearch,
  required final ValueChanged<String>? onSubmittedSearch,
}) {
  const double space = 10;
  final bool isSearching = ctx.isSearching;

  // 🎨 Defaults reales usando la paleta MeetClic
  final Color resolvedFillColor =
      searchStyle.fillColor ?? AppColors.blanco; // fondo blanco limpio

  final Color resolvedBorderColor =
      searchStyle.borderColor ?? AppColors.azulClic.withOpacity(0.15);

  final Color resolvedFocusedBorderColor =
      searchStyle.focusedBorderColor ?? AppColors.azulClic;

  final Color resolvedCursorColor =
      searchStyle.cursorColor ?? AppColors.azulClic;

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(searchStyle.borderRadius),
      borderSide: BorderSide(color: color, width: searchStyle.borderWidth),
    );
  }

  // ========= CENTRO =========
  final Widget centerContent = isSearching
      ? TextField(
          controller: ctx.searchController,
          focusNode: ctx.searchFocusNode,
          cursorColor: searchStyle.cursorColor,
          style:
              searchStyle.textStyle ??
              const TextStyle(fontSize: 16, color: AppColors.grisOscuro),
          decoration: InputDecoration(
            hintText: searchStyle.hintText,
            hintStyle:
                searchStyle.hintStyle ??
                const TextStyle(fontSize: 16, color: Colors.grey),
            isDense: true,
            filled: searchStyle.filled,
            fillColor: resolvedFillColor,
            contentPadding: searchStyle.contentPadding,
            border: _buildBorder(resolvedBorderColor),
            enabledBorder: _buildBorder(resolvedBorderColor),
            focusedBorder: _buildBorder(resolvedFocusedBorderColor),
          ),
          onChanged: (value) {
            onChangedSearch!(value);
          },
          onSubmitted: (value) {
            onSubmittedSearch!(value);
          },
        )
      : Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Meetclic',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.azulClic,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  // ========= DERECHA (botones normales, generados dinámicamente) =========
  final List<Widget> rightChildren = [];

  for (int i = 0; i < rightActions.length; i++) {
    final action = rightActions[i];
    if (isSearching && action.hideWhenSearching) continue;

    rightChildren.add(GestureDetector(onTap: action.onTap, child: action.icon));

    if (i < rightActions.length - 1) {
      rightChildren.add(const SizedBox(width: space));
    }
  }

  final Widget rightButtons = Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: rightChildren,
  );

  // ========= IZQUIERDA (back solo en búsqueda) =========
  final Widget leftBackButton = Padding(
    padding: searchStyle.backIconPadding,
    child: GestureDetector(
      onTap: ctx.stopSearch,
      child: Icon(
        searchStyle.backIcon,
        size: searchStyle.backIconSize,
        color: searchStyle.backIconColor,
      ),
    ),
  );

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: const [0.20, 0.50, 0.30],
    sections: [
      // IZQUIERDA
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: leftBackButton,
        visible: isSearching,
      ),
      // CENTRO
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: centerContent,
        visible: true,
      ),
      // DERECHA
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: rightButtons,
        visible: true,
      ),
    ],
  );
}

HeaderLayoutConfiguration buildMeetclicHeaderLayout({
  required SearchHeaderContext ctx,
  required AppConfig config,
  required List<HeaderActionItem> rightActions, // 👈 nuevo
}) {
  const double space = 10;
  final bool isSearching = ctx.isSearching;
  // ========= CENTRO =========
  final Widget centerContent = isSearching
      ? TextField(
          controller: ctx.searchController,
          focusNode: ctx.searchFocusNode,
          decoration: const InputDecoration(
            hintText: 'Buscar en MeetClic',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onChanged: (value) {
            print('Buscar onChanged');
          },
          onSubmitted: (value) {
            // igual: puedes conectar con onSearchSubmitted del widget
            print('Buscar onSubmitted: $value');
          },
        )
      : Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Meetclic',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.azulClic,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  // ========= DERECHA (botones normales, generados dinámicamente) =========
  final List<Widget> rightChildren = [];

  for (int i = 0; i < rightActions.length; i++) {
    final action = rightActions[i];
    if (isSearching && action.hideWhenSearching) continue;
    rightChildren.add(GestureDetector(onTap: action.onTap, child: action.icon));
    if (i < rightActions.length - 1) {
      rightChildren.add(const SizedBox(width: space));
    }
  }
  final Widget rightButtons = Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: rightChildren,
  );
  // ========= IZQUIERDA (back solo en búsqueda) =========
  final Widget leftBackButton = GestureDetector(
    onTap: ctx.stopSearch, // 👈 SALE DE MODO SEARCH
    child: const Icon(Icons.arrow_back, size: 24),
  );

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: const [0.20, 0.50, 0.30],
    sections: [
      // IZQUIERDA
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: leftBackButton,
        visible: isSearching, // solo aparece en búsqueda
      ),
      // CENTRO
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: centerContent,
        visible: true,
      ),
      // DERECHA
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: rightButtons,
        visible: true,
      ),
    ],
  );
}
