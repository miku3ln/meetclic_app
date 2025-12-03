import 'package:flutter/material.dart';

import '../../models/filter_category_model.dart';
import '../../theme/business_filters_colors.dart';

class SubcategoryCheckboxAtom extends StatelessWidget {
  final FilterSubcategory subcategory;
  final bool isSelected;
  final BusinessFiltersColors colors;
  final ValueChanged<bool> onChanged;

  const SubcategoryCheckboxAtom({
    super.key,
    required this.subcategory,
    required this.isSelected,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),

      child: CheckboxListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
        ), // 👈 pegado a la izquierda
        secondary: Icon(
          subcategory.icon,
          size: 18,
          color: colors.categoryIconColor,
        ),
        title: Text(
          subcategory.name,
          style: TextStyle(color: colors.categoryItemTextColor),
        ),
        value: isSelected,
        onChanged: (value) => onChanged(value ?? false),
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: colors.checkboxActiveColor,
        checkColor: colors.checkboxCheckColor,
      ),
    );
  }
}
