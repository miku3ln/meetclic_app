import 'package:flutter/material.dart';

import '../../state/business_filters_state.dart';

/// 🎨 Paleta específica para la barra de búsqueda
class TopSearchBarColors {
  // Fondo de la barra
  final Color backgroundColor;

  // Icono lupa de búsqueda
  final Color searchIconColor;

  // Texto del hint "Buscar negocios..."
  final Color hintTextColor;

  // Texto que escribe el usuario
  final Color inputTextColor;

  // Texto del botón "Buscar"
  final Color searchButtonTextColor;

  // Icono del botón de filtros
  final Color filtersIconColor;

  const TopSearchBarColors({
    required this.backgroundColor,
    required this.searchIconColor,
    required this.hintTextColor,
    required this.inputTextColor,
    required this.searchButtonTextColor,
    required this.filtersIconColor,
  });

  /// Valores por defecto basados en el theme
  factory TopSearchBarColors.fromTheme(ThemeData theme) {
    final cs = theme.colorScheme;
    final onSurface = cs.onSurface;
    final primary = cs.primary;
    final card = Colors.white;

    return TopSearchBarColors(
      backgroundColor: card,
      searchIconColor: onSurface,
      hintTextColor: onSurface.withOpacity(0.6),
      inputTextColor: onSurface,
      searchButtonTextColor: primary,
      filtersIconColor: primary,
    );
  }
}

class TopSearchBarMolecule extends StatefulWidget {
  final BusinessFiltersState filtersState;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmit;
  final VoidCallback onOpenFilters;
  final TopSearchBarColors? colors;

  const TopSearchBarMolecule({
    super.key,
    required this.filtersState,
    required this.onSearchChanged,
    required this.onSearchSubmit,
    required this.onOpenFilters,
    this.colors,
  });

  @override
  State<TopSearchBarMolecule> createState() => _TopSearchBarMoleculeState();
}

class _TopSearchBarMoleculeState extends State<TopSearchBarMolecule> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.filtersState.searchQuery);
  }

  @override
  void didUpdateWidget(covariant TopSearchBarMolecule oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 SOLO actualiza si el valor viene de afuera (ej: filtros aplicados)
    if (oldWidget.filtersState.searchQuery != widget.filtersState.searchQuery) {
      _controller.text = widget.filtersState.searchQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColors = widget.colors ?? TopSearchBarColors.fromTheme(theme);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      color: resolvedColors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.search, color: resolvedColors.searchIconColor),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onSearchChanged,
                onSubmitted: (_) => widget.onSearchSubmit(),
                textInputAction: TextInputAction.search,
                style: TextStyle(color: resolvedColors.inputTextColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Buscar negocios...',
                  hintStyle: TextStyle(color: resolvedColors.hintTextColor),
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onSearchSubmit,
              child: Text(
                "Buscar",
                style: TextStyle(color: resolvedColors.searchButtonTextColor),
              ),
            ),
            IconButton(
              onPressed: widget.onOpenFilters,
              icon: Icon(Icons.tune, color: resolvedColors.filtersIconColor),
            ),
          ],
        ),
      ),
    );
  }
}
