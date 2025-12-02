// search_language_app_bar.dart
import 'package:flutter/material.dart';

import 'language_drop_down.dart';

class SearchLanguageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TextEditingController controller;

  /// Se buscará SOLAMENTE por onChanged (tecleo).
  final ValueChanged<String> onChanged;

  /// Opcional si quieres capturar "enter", pero no es necesario para buscar.
  final ValueChanged<String>? onSubmitted;

  /// Callback al tocar el icono de filtros (derecha dentro del input).
  final VoidCallback onFilterTap;

  final String language;
  final ValueChanged<String> onLanguageChanged;

  /// Altura total del AppBar.
  final double height;

  const SearchLanguageAppBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.language,
    required this.onLanguageChanged,
    this.onSubmitted,
    this.height = 76,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: height,
      titleSpacing: 16,
      title: Row(
        children: [
          // ---------- SEARCH PILL ----------
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000), // ~10% black
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 10),
                  // TextField (search by onChanged)
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged, // 🔍 búsqueda en tiempo real
                      onSubmitted: onSubmitted, // (opcional)
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        hintText: 'Search words...',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  // Icono Filtros (derecha dentro del pill)
                  IconButton(
                    tooltip: 'Filters',
                    splashRadius: 22,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.tune_rounded,
                      size: 22,
                      color: Colors.black87,
                    ),
                    onPressed: onFilterTap, // ✅ callback de filtros
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ---------- LANG DROPDOWN PILL ----------
          LanguageDropdown(
            value: language,
            onChanged: onLanguageChanged,
            height: 52,
          ),
        ],
      ),
    );
  }
}
