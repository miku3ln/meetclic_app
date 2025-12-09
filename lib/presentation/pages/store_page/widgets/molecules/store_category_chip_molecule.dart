import 'package:flutter/material.dart';

import '../../models/store_category_model.dart';
import '../../theme/store_theme.dart';
import '../atoms/store_category_icon_atom.dart';

class StoreCategoryChipMolecule extends StatelessWidget {
  final StoreCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const StoreCategoryChipMolecule({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? StoreTheme.categorySelectedText
        : StoreTheme.categoryUnselectedText;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StoreCategoryIconAtom(icon: category.icon, isSelected: isSelected),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
