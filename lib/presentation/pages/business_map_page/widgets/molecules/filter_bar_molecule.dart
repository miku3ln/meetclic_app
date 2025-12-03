import 'package:flutter/material.dart';

import '../atoms/category_icon_atom.dart';
import '../atoms/distance_chip_atom.dart';

class FilterBarMolecule extends StatelessWidget {
  final double selectedDistanceKm;
  final List<FilterCategoryUiModel> categories;
  final ValueChanged<double> onDistanceTap;
  final ValueChanged<String> onCategoryTap;
  final VoidCallback onOpenFilters;

  const FilterBarMolecule({
    super.key,
    required this.selectedDistanceKm,
    required this.categories,
    required this.onDistanceTap,
    required this.onCategoryTap,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // “Handle” de arrastre visual
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DistanceChipAtom(
                  label:
                      'Distancia: ${selectedDistanceKm.toStringAsFixed(0)} km',
                  isSelected: true,
                  onTap: () => onDistanceTap(selectedDistanceKm),
                ),
                const SizedBox(width: 8),
                ...categories.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryIconAtom(
                      icon: c.icon,
                      label: c.label,
                      isSelected: c.isSelected,
                      onTap: () => onCategoryTap(c.id),
                    ),
                  );
                }).toList(),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onOpenFilters,
                  icon: const Icon(Icons.expand_less),
                  label: const Text('Más filtros'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelo de UI simple para categorías
class FilterCategoryUiModel {
  final String id;
  final IconData icon;
  final String label;
  final bool isSelected;

  const FilterCategoryUiModel({
    required this.id,
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  FilterCategoryUiModel copyWith({bool? isSelected}) => FilterCategoryUiModel(
    id: id,
    icon: icon,
    label: label,
    isSelected: isSelected ?? this.isSelected,
  );
}
