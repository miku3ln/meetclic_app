import 'package:flutter/material.dart';

import '../../models/store_category_model.dart';
import '../molecules/store_category_chip_molecule.dart';

class StoreCategoriesListOrganism extends StatelessWidget {
  final List<StoreCategoryModel> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onCategorySelected;

  const StoreCategoriesListOrganism({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final cat = categories[index];
          final isSelected = cat.id == selectedCategoryId;
          return StoreCategoryChipMolecule(
            category: cat,
            isSelected: isSelected,
            onTap: () => onCategorySelected(cat.id),
          );
        },
      ),
    );
  }
}
