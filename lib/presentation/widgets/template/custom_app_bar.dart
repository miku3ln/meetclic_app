import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/shared/models/app_config.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<MenuTabUpItem> items;
  final String title;
  final bool borderAllow;
  final Color backgroundColor;
  final Color? textColor; // ✅ color opcional para texto (título y números)
  // 👇 Config opcional para el leading
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final Color? leadingIconColor;
  const CustomAppBar({
    super.key,
    required this.title,
    required this.items,
    this.borderAllow = true,
    this.backgroundColor = Colors.white,
    this.textColor, // si no se envía, se usa el del theme
    this.leadingIcon,
    this.onLeadingPressed,
    this.leadingIconColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appConfig = Provider.of<AppConfig>(context);
    final bool hasTitle = title.trim().isNotEmpty && !(textColor == null);
    final Color resolvedTextColor = textColor ?? backgroundColor;
    final bool hasLeading = leadingIcon != null && onLeadingPressed != null;
    return AppBar(
      elevation: 0,
      titleSpacing: 12,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: hasLeading
          ? IconButton(
              icon: Icon(
                leadingIcon,
                color: leadingIconColor ?? resolvedTextColor,
              ),
              onPressed: onLeadingPressed,
            )
          : null,
      // elimina el tinte que aparece al hacer scroll
      scrolledUnderElevation: 0,
      // evita sombra + efecto “scrolledUnder” (opcional)
      shape: borderAllow
          ? Border(bottom: BorderSide(color: AppColors.borderSoft, width: 0.8))
          : null,
      title: Row(
        children: [
          // ✅ Solo mostramos el título si viene texto
          if (hasTitle) ...[
            Text(
              title,
              style:
                  (theme.appBarTheme.titleTextStyle ??
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ))
                      .copyWith(color: resolvedTextColor),
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
                          // Ícono
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
      ),
    );
  }
}
