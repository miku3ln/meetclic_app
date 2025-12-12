import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/models/app_config.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/menu_tab_up_item.dart';
import '../../../shared/themes/app_colors.dart';
import 'custom_app_bar/models/custom_app_bar_all_model.dart';

// ===============================================
//              CUSTOM APP BAR
// ===============================================
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // 🔹 Config visual del contenedor (se mantiene)
  final bool borderAllow;
  final Color backgroundColor;
  final Color? textColor;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final Color? leadingIconColor;

  // 🔹 Datos “clásicos”
  final String title;
  final List<MenuTabUpItem> items;

  // 🔹 NUEVO: configuración completa del header (opcional)
  final HeaderLayoutConfiguration? config;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.items,
    this.config,
    this.borderAllow = true,
    this.backgroundColor = Colors.white,
    this.textColor,
    this.leadingIcon,
    this.onLeadingPressed,
    this.leadingIconColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appConfig = Provider.of<AppConfig>(context); // por si luego lo usas
    final Color resolvedTextColor =
        textColor ?? theme.appBarTheme.foregroundColor ?? Colors.black;
    final bool hasLeading = leadingIcon != null && onLeadingPressed != null;

    // 👇 Si no envías config, usamos el preset NONE
    final effectiveConfig = config ?? HeaderLayoutPresets.none;

    return AppBar(
      toolbarHeight: 150,
      elevation: 0,
      titleSpacing: 12,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      leading: hasLeading
          ? IconButton(
              icon: Icon(
                leadingIcon,
                color: leadingIconColor ?? resolvedTextColor,
              ),
              onPressed: onLeadingPressed,
            )
          : null,
      shape: borderAllow
          ? Border(bottom: BorderSide(color: AppColors.borderSoft, width: 0.8))
          : null,
      title: _buildLayoutContent(theme, resolvedTextColor, effectiveConfig),
    );
  }

  // --------- construir contenido según layout + porcentajes ---------

  Widget _buildLayoutContent(
    ThemeData theme,
    Color defaultTextColor,
    HeaderLayoutConfiguration effectiveConfig,
  ) {
    // 🧷 Caso especial: layout NONE → usamos comportamiento “viejo”
    if (effectiveConfig.layoutType == HeaderLayoutType.none) {
      return _buildLegacyTitleAndItems(theme, defaultTextColor);
    }

    final perc = effectiveConfig.percentages;
    final sections = effectiveConfig.sections;

    return Row(
      children: List.generate(sections.length, (index) {
        final section = sections[index];
        final flex = (perc[index] * 1000).toInt();

        if (!section.visible || section.type == HeaderSectionType.none) {
          return const SizedBox.shrink();
        }

        return Expanded(
          flex: flex,
          child: GestureDetector(
            onTap: section.onTap,
            child: section.content ?? const SizedBox.shrink(),
          ),
        );
      }),
    );
  }

  /// 🧩 Layout "clásico": Título + items scroll horizontales
  Widget _buildLegacyTitleAndItems(ThemeData theme, Color textColor) {
    final bool hasTitle = title.trim().isNotEmpty;

    return Row(
      children: [
        if (hasTitle) ...[
          Text(
            title,
            style:
                (theme.appBarTheme.titleTextStyle ??
                        const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ))
                    .copyWith(color: textColor),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                return GestureDetector(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.number.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Image.asset(item.asset, width: 30, height: 30),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchHeaderContext {
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  /// Llamar para entrar en modo búsqueda
  final VoidCallback startSearch;

  /// Llamar para salir de búsqueda
  final VoidCallback stopSearch;

  const SearchHeaderContext({
    required this.isSearching,
    required this.searchController,
    required this.searchFocusNode,
    required this.startSearch,
    required this.stopSearch,
  });
}

class HeaderAppBarStyle {
  final Color backgroundColor;
  final Color? foregroundColor; // color por defecto de íconos / texto
  final double elevation;
  final bool centerTitle;
  final double height;

  // Borde inferior opcional
  final Color? bottomBorderColor;
  final double bottomBorderWidth;

  // Padding general para el contenido interno
  final EdgeInsetsGeometry contentPadding;

  const HeaderAppBarStyle({
    this.backgroundColor = Colors.white,
    this.foregroundColor,
    this.elevation = 0.0,
    this.centerTitle = false,
    this.height = kToolbarHeight,
    this.bottomBorderColor,
    this.bottomBorderWidth = 0,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 8),
  });

  /// Estilo por defecto MeetClic (puedes ajustarlo)
  static const meetclic = HeaderAppBarStyle(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    contentPadding: EdgeInsets.symmetric(horizontal: 8),
  );
}

class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  final HeaderLayoutConfiguration Function(
    bool isSearching,
    TextEditingController controller,
    FocusNode focusNode,
    HeaderSearchBehavior behavior,
  )
  layoutBuilder;

  final HeaderAppBarStyle style;

  final HeaderSearchBehavior searchBehavior;

  const SearchableAppBar({
    super.key,
    required this.layoutBuilder,
    this.style = HeaderAppBarStyle.meetclic,
    this.searchBehavior = const HeaderSearchBehavior(),
  });

  @override
  Size get preferredSize => Size.fromHeight(style.height);

  @override
  State<SearchableAppBar> createState() => _SearchableAppBarState();
}

class _SearchableAppBarState extends State<SearchableAppBar> {
  bool _isSearching = false;
  final controller = TextEditingController();
  final focusNode = FocusNode();

  void _startSearch() {
    setState(() => _isSearching = true);
    Future.microtask(() => focusNode.requestFocus());
  }

  void _stopSearch() {
    setState(() => _isSearching = false);
    controller.clear();
    focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.layoutBuilder(
      _isSearching,
      controller,
      focusNode,
      widget.searchBehavior,
    );

    final sections = config.sections;
    final percents = config.percentages;

    return AppBar(
      backgroundColor: widget.style.backgroundColor,
      elevation: widget.style.elevation,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: List.generate(sections.length, (i) {
          final section = sections[i];
          if (!section.visible) return const SizedBox.shrink();
          final flex = (percents[i] * 1000).round();
          return Expanded(
            flex: flex,
            child: section.content ?? const SizedBox(),
          );
        }),
      ),
    );
  }

  // Exposed so you can attach them inside layoutBuilder
  void startSearch() => _startSearch();

  void stopSearch() => _stopSearch();
}

class HeaderSearchBehavior {
  final bool hideCenterContent;
  final bool hideRightButtons;
  final bool hideLeftButtons;
  final bool showSearchInput;
  final bool showBackButton;

  const HeaderSearchBehavior({
    this.hideCenterContent = true,
    this.hideRightButtons = true,
    this.hideLeftButtons = true,
    this.showSearchInput = true,
    this.showBackButton = true,
  });
}

class SearchableHeaderAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  /// Estilo visual del AppBar (bordes, fondo, altura, etc.)
  final HeaderAppBarStyle style;

  /// Builder que construye el layout según el estado de búsqueda
  final HeaderLayoutConfiguration Function(SearchHeaderContext ctx)
  layoutBuilder;

  /// Callbacks opcionales sobre el texto de búsqueda
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const SearchableHeaderAppBar({
    super.key,
    required this.layoutBuilder,
    this.style = HeaderAppBarStyle.meetclic,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize => Size.fromHeight(style.height);

  @override
  State<SearchableHeaderAppBar> createState() => _SearchableHeaderAppBarState();
}

class _SearchableHeaderAppBarState extends State<SearchableHeaderAppBar> {
  bool _isSearching = false;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    Future.microtask(() => _searchFocusNode.requestFocus());
  }

  void _stopSearch() {
    setState(() => _isSearching = false);
    _searchController.clear();
    _searchFocusNode.unfocus();
    widget.onSearchChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final ctx = SearchHeaderContext(
      isSearching: _isSearching,
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      startSearch: _startSearch,
      stopSearch: _stopSearch,
    );

    final config = widget.layoutBuilder(ctx);
    final sections = config.sections;
    final percentages = config.percentages;

    final theme = Theme.of(context);
    final fgColor =
        widget.style.foregroundColor ?? theme.appBarTheme.foregroundColor;

    return AppBar(
      shape: config.borderAllow
          ? Border(bottom: BorderSide(color: AppColors.borderSoft, width: 0.8))
          : null,
      backgroundColor: widget.style.backgroundColor,
      elevation: widget.style.elevation,
      automaticallyImplyLeading: false,
      centerTitle: widget.style.centerTitle,
      titleSpacing: 0,
      iconTheme: fgColor != null ? IconThemeData(color: fgColor) : null,
      title: Padding(
        padding: widget.style.contentPadding,
        child: Row(
          children: List.generate(sections.length, (i) {
            final section = sections[i];
            if (!section.visible) return const SizedBox.shrink();

            final flex = (percentages[i] * 1000).round();
            return Expanded(
              flex: flex,
              child: section.content ?? const SizedBox.shrink(),
            );
          }),
        ),
      ),
      bottom:
          (widget.style.bottomBorderColor != null &&
              widget.style.bottomBorderWidth > 0)
          ? PreferredSize(
              preferredSize: Size.fromHeight(widget.style.bottomBorderWidth),
              child: Container(
                color: widget.style.bottomBorderColor,
                height: widget.style.bottomBorderWidth,
              ),
            )
          : null,
    );
  }
}

class HeaderActionItem {
  final Widget icon; // el widget del icono (Image, Icon, etc.)
  final VoidCallback onTap; // lo que hace al tocar
  final bool hideWhenSearching;

  const HeaderActionItem({
    required this.icon,
    required this.onTap,
    this.hideWhenSearching = true, // por defecto se ocultan en search
  });
}

class HeaderSearchVisualConfig {
  // INPUT
  final String hintText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry contentPadding;
  final Color? cursorColor;

  // BOTÓN BACK
  final IconData backIcon;
  final double backIconSize;
  final Color? backIconColor;
  final EdgeInsetsGeometry backIconPadding;
  // FONDO
  final bool filled;
  final Color? fillColor;

  // BORDE
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final double borderWidth;
  const HeaderSearchVisualConfig({
    // INPUT
    this.hintText = 'Buscar en MeetClic',
    this.textStyle,
    this.hintStyle,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.cursorColor,

    // BACK
    this.backIcon = Icons.arrow_back,
    this.backIconSize = 24,
    this.backIconColor,
    this.backIconPadding = const EdgeInsets.only(right: 8),

    this.filled = true,
    this.fillColor,
    // MeetClic: colores se resuelven en el build si son null
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius = 24,
    this.borderWidth = 1,
  });

  static const defaults = HeaderSearchVisualConfig();
}
