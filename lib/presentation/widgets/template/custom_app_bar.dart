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
