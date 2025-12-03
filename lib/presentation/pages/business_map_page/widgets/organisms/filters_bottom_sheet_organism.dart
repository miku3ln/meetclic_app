import 'package:flutter/material.dart';

import '../atoms/category_icon_atom.dart';
import '../atoms/distance_chip_atom.dart';
import '../molecules/filter_bar_molecule.dart'; // por el modelo FilterCategoryUiModel

class FiltersBottomSheetOrganism extends StatelessWidget {
  final double selectedDistanceKm;
  final List<FilterCategoryUiModel> categories;
  final ValueChanged<double> onDistanceChanged;
  final ValueChanged<String> onCategoryChanged;

  const FiltersBottomSheetOrganism({
    super.key,
    required this.selectedDistanceKm,
    required this.categories,
    required this.onDistanceChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text('Filtros', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            // Distancia
            Text('Distancia', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                DistanceChipAtom(
                  label: '${selectedDistanceKm.toStringAsFixed(0)} km',
                  isSelected: true,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: selectedDistanceKm,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '${selectedDistanceKm.toStringAsFixed(0)} km',
                    onChanged: onDistanceChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categorías
            Text('Categorías', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((c) {
                return CategoryIconAtom(
                  icon: c.icon,
                  label: c.label,
                  isSelected: c.isSelected,
                  onTap: () => onCategoryChanged(c.id),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
