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

class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const SearchableAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchableAppBar> createState() => _SearchableAppBarState();
}

class _SearchableAppBarState extends State<SearchableAppBar> {
  bool _isSearching = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Entrar a modo búsqueda
  void _startSearch() {
    setState(() => _isSearching = true);

    // Espera un microtask para que se abra el teclado
    Future.delayed(const Duration(milliseconds: 50), () {
      _focusNode.requestFocus();
    });
  }

  // Salir de modo búsqueda
  void _stopSearch() {
    setState(() => _isSearching = false);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Manejas tu propio botón back
      titleSpacing: 0,

      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _stopSearch,
            )
          : null,

      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSearching
            ? TextField(
                key: const ValueKey("searchField"),
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Buscar',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (text) {
                  // Aquí filtras los resultados si quieres
                },
              )
            : Padding(
                key: const ValueKey("normalTitle"),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(widget.title),
              ),
      ),

      actions: _isSearching
          ? [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _controller.clear()),
                ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _startSearch,
              ),
            ],
    );
  }
}
