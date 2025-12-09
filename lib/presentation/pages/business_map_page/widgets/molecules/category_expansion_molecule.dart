import 'package:flutter/material.dart';

import '../../models/filter_category_model.dart';
import '../../theme/business_filters_colors.dart';
import '../atoms/subcategory_checkbox_atom.dart';

class CategoryExpansionMolecule extends StatelessWidget {
  final FilterCategory category;
  final Set<String> selectedSubcategoryIds;
  final BusinessFiltersColors colors;
  final ValueChanged<String> onToggleSubcategory;

  const CategoryExpansionMolecule({
    super.key,
    required this.category,
    required this.selectedSubcategoryIds,
    required this.colors,
    required this.onToggleSubcategory,
  });

  bool get _hasAnySelected =>
      category.subcategories.any((s) => selectedSubcategoryIds.contains(s.id));

  bool get _isAllSelected =>
      category.subcategories.isNotEmpty &&
      category.subcategories.every(
        (s) => selectedSubcategoryIds.contains(s.id),
      );

  @override
  Widget build(BuildContext context) {
    // Cambios de color cuando hay subcategorías seleccionadas
    final Color iconBgColor = _hasAnySelected
        ? colors.checkboxActiveColor.withOpacity(0.15)
        : colors.categoryIconBackgroundColor;

    final Color iconColor = _hasAnySelected
        ? colors.checkboxActiveColor
        : colors.categoryIconColor;

    final Color textColor = _hasAnySelected
        ? colors.checkboxActiveColor
        : colors.categoryItemTextColor;

    final FontWeight textWeight = _hasAnySelected
        ? FontWeight.w600
        : FontWeight.normal;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 28, right: 8, bottom: 8),

      // ICONO DE CATEGORÍA (círculo de la izquierda)
      leading: CircleAvatar(
        backgroundColor: iconBgColor,
        child: Icon(category.icon, size: 18, color: iconColor),
      ),

      // NOMBRE DE CATEGORÍA
      title: Text(
        category.name,
        style: TextStyle(color: textColor, fontWeight: textWeight),
      ),

      // ✅ CHECKBOX DE CABECERA (seleccionar/deseleccionar TODAS)
      trailing: Checkbox(
        value: _isAllSelected,
        onChanged: (value) {
          final shouldSelectAll = value ?? false;

          for (final sub in category.subcategories) {
            final isSelected = selectedSubcategoryIds.contains(sub.id);

            if (shouldSelectAll && !isSelected) {
              // seleccionar las que faltan
              onToggleSubcategory(sub.id);
            } else if (!shouldSelectAll && isSelected) {
              // deseleccionar las que estaban
              onToggleSubcategory(sub.id);
            }
          }
        },
        activeColor: colors.checkboxActiveColor,
        checkColor: colors.checkboxCheckColor,
      ),

      // SOLO las subcategorías
      children: category.subcategories.map((sub) {
        final selected = selectedSubcategoryIds.contains(sub.id);

        return SubcategoryCheckboxAtom(
          subcategory: sub,
          isSelected: selected,
          colors: colors,
          onChanged: (_) => onToggleSubcategory(sub.id),
        );
      }).toList(),
    );
  }
}
