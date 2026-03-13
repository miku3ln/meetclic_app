import 'package:flutter/material.dart';

import '../../../infrastructure/assets/app_images.dart';
import '../../../shared/models/app_config.dart';

import '../../../shared/theme/configuration/app_theme_tokens.dart';
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

HeaderLayoutConfiguration buildSearchHeaderLayoutOther({
  required SearchHeaderContext ctx,
  required AppConfig config,
  required List<HeaderActionItem> rightActions,
  HeaderSearchVisualConfig searchStyle = HeaderSearchVisualConfig.defaults,
  ValueChanged<String>? onChangedSearch,
  ValueChanged<String>? onSubmittedSearch,
}) {
  const double space = 10;
  final bool isSearching = ctx.isSearching;

  // === defaults MeetClic ===
  final Color resolvedFillColor = searchStyle.fillColor ?? AppColors.blanco;
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

  // ========= WIDGET TÍTULO / INPUT =========
  Widget buildSearchTextField() {
    return TextField(
      controller: ctx.searchController,
      focusNode: ctx.searchFocusNode,
      cursorColor: resolvedCursorColor,
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
        if (onChangedSearch != null) onChangedSearch(value);
      },
      onSubmitted: (value) {
        if (onSubmittedSearch != null) onSubmittedSearch(value);
      },
    );
  }

  const titleWidget = Align(
    alignment: Alignment.centerLeft,
    child: Text(
      'Meetclic',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.azulClic,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // ========= ACCIONES =========
  final normalActions = rightActions; // todas
  final searchActions = rightActions
      .where((a) => !a.hideWhenSearching)
      .toList(); // visibles en search

  // ========= MODO BÚSQUEDA =========
  if (isSearching) {
    // back común
    final backButton = GestureDetector(
      onTap: ctx.stopSearch,
      child: const Icon(Icons.arrow_back, size: 22, color: AppColors.azulClic),
    );

    if (searchActions.isEmpty) {
      // 🔹 NO HAY BOTONES EN BÚSQUEDA → 20 / 80 (back + input)
      return HeaderLayoutConfiguration(
        layoutType: HeaderLayoutType.doubleColumnLeftWeighted,
        percentages: const [0.20, 0.80],
        sections: [
          HeaderSectionModel(
            type: HeaderSectionType.buttons,
            content: backButton,
            visible: true,
          ),
          HeaderSectionModel(
            type: HeaderSectionType.textInput,
            content: buildSearchTextField(),
            visible: true,
          ),
        ],
      );
    } else {
      // 🔹 SÍ HAY BOTONES EN BÚSQUEDA → 20 / 65 / 15 (back + input + botones)
      final List<Widget> rightSearchChildren = [];
      for (int i = 0; i < searchActions.length; i++) {
        final action = searchActions[i];
        rightSearchChildren.add(
          GestureDetector(onTap: action.onTap, child: action.icon),
        );
        if (i < searchActions.length - 1) {
          rightSearchChildren.add(const SizedBox(width: space));
        }
      }

      final rightSearchRow = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: rightSearchChildren,
      );

      return HeaderLayoutConfiguration(
        layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
        percentages: const [0.20, 0.65, 0.15],
        sections: [
          HeaderSectionModel(
            type: HeaderSectionType.buttons,
            content: backButton,
            visible: true,
          ),
          HeaderSectionModel(
            type: HeaderSectionType.textInput,
            content: buildSearchTextField(),
            visible: true,
          ),
          HeaderSectionModel(
            type: HeaderSectionType.buttons,
            content: rightSearchRow,
            visible: true,
          ),
        ],
      );
    }
  }

  // ========= MODO NORMAL (20 / 50 / 30) =========
  final List<Widget> rightNormalChildren = [];
  for (int i = 0; i < normalActions.length; i++) {
    final action = normalActions[i];
    rightNormalChildren.add(
      GestureDetector(onTap: action.onTap, child: action.icon),
    );
    if (i < normalActions.length - 1) {
      rightNormalChildren.add(const SizedBox(width: space));
    }
  }

  final rightNormalRow = Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: rightNormalChildren,
  );

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: const [0.20, 0.50, 0.30],
    sections: [
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: const SizedBox(), // nada a la izquierda
        visible: true,
      ),
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: titleWidget,
        visible: true,
      ),
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: rightNormalRow,
        visible: true,
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

HeaderLayoutConfiguration buildSearchHeaderLayout20_80({
  required SearchHeaderContext ctx,
  HeaderSearchVisualConfig searchStyle = HeaderSearchVisualConfig.defaults,
  ValueChanged<String>? onChangedSearch,
  ValueChanged<String>? onSubmittedSearch,
}) {
  // 20 = back
  final backButton = Padding(
    padding: searchStyle.backIconPadding,
    child: IconButton(
      icon: Icon(
        searchStyle.backIcon,
        size: searchStyle.backIconSize,
        color: searchStyle.backIconColor ?? AppColors.azulClic,
      ),
      onPressed: ctx.stopSearch,
    ),
  );

  // 80 = input (usa el helper de arriba)
  final input = buildSearchTextField(
    ctx: ctx,
    searchStyle: searchStyle,
    onChangedSearch: onChangedSearch,
    onSubmittedSearch: onSubmittedSearch,
  );

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.doubleColumnLeftWeighted,
    percentages: const [0.20, 0.80],
    sections: [
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: Align(alignment: Alignment.centerLeft, child: backButton),
        visible: true,
      ),
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: Align(
          alignment:
              Alignment.centerLeft, // centrado vertical dentro del AppBar
          child: input,
        ),
        visible: true,
      ),
    ],
  );
}

Widget buildSearchTextField({
  required SearchHeaderContext ctx,
  required HeaderSearchVisualConfig searchStyle,
  ValueChanged<String>? onChangedSearch,
  ValueChanged<String>? onSubmittedSearch,
}) {
  // 🎨 Colores
  final Color resolvedFillColor = searchStyle.fillColor ?? AppColors.blanco;
  final Color resolvedBorderColor =
      searchStyle.borderColor ?? AppColors.azulClic.withOpacity(0.15);
  final Color resolvedFocusedBorderColor =
      searchStyle.focusedBorderColor ?? AppColors.azulClic;
  final Color resolvedCursorColor =
      searchStyle.cursorColor ?? AppColors.azulClic;

  // 🎨 Estilos base + merge
  const TextStyle baseTextStyle = TextStyle(
    fontSize: 16,
    color: AppColors.grisOscuro,
  );
  const TextStyle baseHintStyle = TextStyle(fontSize: 16, color: Colors.grey);

  final TextStyle resolvedTextStyle = baseTextStyle.merge(
    searchStyle.textStyle,
  );
  final TextStyle resolvedHintStyle = baseHintStyle.merge(
    searchStyle.hintStyle,
  );

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(searchStyle.borderRadius),
      borderSide: BorderSide(color: color, width: searchStyle.borderWidth),
    );
  }

  // 🧮 Calculamos padding vertical a partir de fieldHeight (aprox)
  // Altura “natural” de la línea ~ 24 px (fontSize 16 * 1.5 aprox)
  const double baseInnerHeight = 24;
  final double desired = searchStyle.fieldHeight; // 40, 44, etc.
  final double extra = (desired - baseInnerHeight).clamp(0, 40);
  final double verticalPadding = extra / 2;
  final contentPadding = searchStyle.contentPadding.add(
    EdgeInsets.symmetric(vertical: verticalPadding),
  );
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 4,
    ), // respiro dentro del AppBar
    child: TextField(
      controller: ctx.searchController,
      focusNode: ctx.searchFocusNode,
      cursorColor: resolvedCursorColor,
      style: resolvedTextStyle,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: searchStyle.hintText,
        hintStyle: resolvedHintStyle,
        isDense: false,
        filled: searchStyle.filled,
        fillColor: resolvedFillColor,
        contentPadding: contentPadding,
        border: _buildBorder(resolvedBorderColor),
        enabledBorder: _buildBorder(resolvedBorderColor),
        focusedBorder: _buildBorder(resolvedFocusedBorderColor),
      ),
      onChanged: (value) => onChangedSearch?.call(value),
      onSubmitted: (value) => onSubmittedSearch?.call(value),
    ),
  );
}

HeaderLayoutConfiguration buildSearchHeaderLayout20_50_302({
  required SearchHeaderContext ctx,
  required List<HeaderActionItem> searchActions, // BOTONES NUEVOS DE SEARCH
  HeaderSearchVisualConfig searchStyle = HeaderSearchVisualConfig.defaults,
  ValueChanged<String>? onChangedSearch,
  ValueChanged<String>? onSubmittedSearch,
}) {
  const double space = 10;

  // 20% = botón regresar
  final backButton = Padding(
    padding: searchStyle.backIconPadding,
    child: IconButton(
      icon: Icon(
        searchStyle.backIcon,
        size: searchStyle.backIconSize,
        color: searchStyle.backIconColor ?? AppColors.azulClic,
      ),
      onPressed: ctx.stopSearch,
    ),
  );

  // 50% = input búsqueda
  final input = buildSearchTextField(
    ctx: ctx,
    searchStyle: searchStyle,
    onChangedSearch: onChangedSearch,
    onSubmittedSearch: onSubmittedSearch,
  );

  // 30% = botones especiales de búsqueda (derecha)
  final List<Widget> rightChildren = [];
  for (int i = 0; i < searchActions.length; i++) {
    final action = searchActions[i];

    rightChildren.add(GestureDetector(onTap: action.onTap, child: action.icon));

    if (i < searchActions.length - 1) {
      rightChildren.add(const SizedBox(width: space));
    }
  }

  final rightButtons = Align(
    alignment: Alignment.centerRight,
    child: FittedBox(
      fit: BoxFit.scaleDown, // evita overflow si son muchos
      child: Row(mainAxisSize: MainAxisSize.min, children: rightChildren),
    ),
  );

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: const [0.10, 0.7, 0.30], // 20 / 50 / 30
    sections: [
      // 20% IZQUIERDA → back
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: Align(alignment: Alignment.centerLeft, child: backButton),
        visible: true,
      ),
      // 50% CENTRO → input
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: Align(alignment: Alignment.centerLeft, child: input),
        visible: true,
      ),
      // 30% DERECHA → botones search
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: rightButtons,
        visible: searchActions.isNotEmpty,
      ),
    ],
  );
}

HeaderLayoutConfiguration buildSearchHeaderLayout20_50_30({
  required SearchHeaderContext ctx,
  required List<HeaderActionItem> searchActions, // solo los de búsqueda
  HeaderSearchVisualConfig searchStyle = HeaderSearchVisualConfig.defaults,
  ValueChanged<String>? onChangedSearch,
  ValueChanged<String>? onSubmittedSearch,
}) {
  const double space = 10;

  // 20 = back
  final backButton = GestureDetector(
    onTap: ctx.stopSearch,
    child: const Icon(Icons.arrow_back, size: 22, color: AppColors.azulClic),
  );

  // 50 = input búsqueda
  final input = buildSearchTextField(
    ctx: ctx,
    searchStyle: searchStyle,
    onChangedSearch: onChangedSearch,
    onSubmittedSearch: onSubmittedSearch,
  );

  // 30 = botones lado derecho (solo los que le pases aquí)
  final List<Widget> rightChildren = [];
  for (int i = 0; i < searchActions.length; i++) {
    final action = searchActions[i];
    rightChildren.add(GestureDetector(onTap: action.onTap, child: action.icon));
    if (i < searchActions.length - 1) {
      rightChildren.add(const SizedBox(width: space));
    }
  }
  final rightButtons = Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: rightChildren,
  );

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: const [0.20, 0.50, 0.30],
    sections: [
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: backButton,
        visible: true,
      ),
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: input,
        visible: true,
      ),
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: rightButtons,
        visible: true,
      ),
    ],
  );
}

HeaderLayoutConfiguration buildNormalHeaderLayout20_50_30({
  required SearchHeaderContext ctx,
  required AppConfig config,
  required List<HeaderActionItem> rightActions,
  String title = 'Meetclic',
  TextStyle? titleTextStyle,
}) {
  const double space = 10;

  // ===== CENTRO (título) =====
  final Widget centerTitle = Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style:
          titleTextStyle ??
          const TextStyle(
            color: AppColors.azulClic,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
    ),
  );

  // ===== DERECHA (botones normales) =====
  final List<Widget> rightChildren = [];
  for (int i = 0; i < rightActions.length; i++) {
    final action = rightActions[i];

    rightChildren.add(GestureDetector(onTap: action.onTap, child: action.icon));

    if (i < rightActions.length - 1) {
      rightChildren.add(const SizedBox(width: space));
    }
  }

  final Widget rightButtons = Align(
    alignment: Alignment.centerRight,
    child: FittedBox(
      fit: BoxFit.scaleDown, // 👈 evita overflow: encoge si no cabe
      child: Row(mainAxisSize: MainAxisSize.min, children: rightChildren),
    ),
  );

  return HeaderLayoutConfiguration(
    layoutType: HeaderLayoutType.tripleColumnCenterWeighted,
    percentages: const [0.03, 0.57, 0.4],
    sections: [
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: const SizedBox(), // 20% izquierda vacío
        visible: true,
      ),
      HeaderSectionModel(
        type: HeaderSectionType.textInput,
        content: centerTitle, // 50% centro
        visible: true,
      ),
      HeaderSectionModel(
        type: HeaderSectionType.buttons,
        content: rightButtons, // 30% derecha (ahora sin overflow)
        visible: true,
      ),
    ],
  );
}

generateSearchAppBar({
  appConfig,
  required VoidCallback onLanguageCallback,
  required VoidCallback onGamificationCallback,
  required VoidCallback onEccomerceCallback,
  required VoidCallback onSearchActionsCallback,
}) {
  return SearchableHeaderAppBar(
    layoutBuilder: (ctx) {
      final String urlFlag = appConfig.getUrlFlag();
      // BOTONES NORMALES (modo normal)
      final normalActions = <HeaderActionItem>[
        HeaderActionItem(
          icon: const Icon(Icons.search, size: 22),
          onTap: ctx.startSearch,
        ),
        HeaderActionItem(
          icon: Image.asset(urlFlag, width: 22, height: 22),
          onTap: onLanguageCallback,
        ),
        HeaderActionItem(
          icon: Image.asset(AppImages.rewardTypeTrophy, width: 22, height: 22),
          onTap: () => onGamificationCallback,
        ),
        HeaderActionItem(
          icon: Image.asset(AppImages.basketEcommerce, width: 24, height: 28),
          onTap: () => onEccomerceCallback,
        ),
      ];

      // BOTONES ESPECIALES SOLO PARA SEARCH (los del 30%)
      final searchActions = <HeaderActionItem>[
        HeaderActionItem(
          icon: const Icon(Icons.tune, size: 22),
          onTap: () => onSearchActionsCallback,
        ),
        // puedes agregar más si quieres
      ];

      const searchStyle = HeaderSearchVisualConfig(
        hintText: 'Buscar tareas',
        fieldHeight: 44,
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        textStyle: TextStyle(fontSize: 16, color: AppColors.azulClic),
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
        cursorColor: AppColors.azulClic,
        backIcon: Icons.arrow_back,
        backIconSize: 20,
        backIconColor: AppColors.azulClic,
        backIconPadding: EdgeInsets.only(right: 4),
      );

      if (ctx.isSearching) {
        // 👉 AQUÍ entra el layout 20/50/30 para búsqueda
        return buildSearchHeaderLayout20_50_302(
          ctx: ctx,
          searchActions: searchActions,
          searchStyle: searchStyle,
          onChangedSearch: (v) => print('onChangedSearch $v'),
          onSubmittedSearch: (v) => print('onSubmittedSearch $v'),
        );
      }

      // 👉 modo normal: título + botones (20/50/30 clásico)
      return buildNormalHeaderLayout20_50_30(
        ctx: ctx,
        config: appConfig,
        rightActions: normalActions,
      );
    },
  );
}
