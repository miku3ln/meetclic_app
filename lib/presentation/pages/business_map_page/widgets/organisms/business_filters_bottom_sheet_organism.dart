import 'package:flutter/material.dart';

import '../../models/filter_category_model.dart';
import '../../state/business_filters_state.dart';
import '../../theme/business_filters_colors.dart';
import '../molecules/category_expansion_molecule.dart';

class BusinessFiltersBottomSheetOrganism extends StatefulWidget {
  final BusinessFiltersState initialState;
  final BusinessFiltersColors? colors;

  const BusinessFiltersBottomSheetOrganism({
    super.key,
    required this.initialState,
    this.colors,
  });

  @override
  State<BusinessFiltersBottomSheetOrganism> createState() =>
      _BusinessFiltersBottomSheetOrganismState();
}

class _BusinessFiltersBottomSheetOrganismState
    extends State<BusinessFiltersBottomSheetOrganism> {
  late double _radiusKm;
  late Set<String> _selectedSubcategoryIds;

  @override
  void initState() {
    super.initState();
    _radiusKm = widget.initialState.radiusKm;
    _selectedSubcategoryIds = Set<String>.from(
      widget.initialState.categoriesIds,
    );
  }

  void _resetAll() {
    setState(() {
      _radiusKm = 10;
      _selectedSubcategoryIds.clear();
    });
  }

  void _applyAndClose() {
    final newState = widget.initialState.copyWith(
      radiusKm: _radiusKm,
      categoriesIds: _selectedSubcategoryIds.toList(),
    );
    Navigator.of(context).pop<BusinessFiltersState>(newState);
  }

  void _toggleSubcategory(String id) {
    setState(() {
      if (_selectedSubcategoryIds.contains(id)) {
        _selectedSubcategoryIds.remove(id);
      } else {
        _selectedSubcategoryIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = widget.colors ?? BusinessFiltersColors.fromTheme(theme);

    final hasAnyFilter = _selectedSubcategoryIds.isNotEmpty || _radiusKm != 10;

    final bgButton = hasAnyFilter
        ? colors.applyButtonBackgroundColor
        : colors.applyButtonDisabledBackgroundColor;
    final textButton = hasAnyFilter
        ? colors.applyButtonTextColor
        : colors.applyButtonDisabledTextColor;

    return SafeArea(
      child: Container(
        color: colors.headerBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: colors.headerIconColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtros',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.headerTitleColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _resetAll,
                    child: Text(
                      'Restablecer',
                      style: TextStyle(color: colors.headerResetColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // DISTANCIA
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Distancia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.distanceTitleColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Muestra negocios dentro de un radio seleccionado.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.distanceSubtitleColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Valor seleccionado (siempre visible)
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.distanceSliderActiveColor.withOpacity(
                            0.15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_radiusKm.toStringAsFixed(0)} km',
                          style: TextStyle(
                            color: colors.distanceSliderActiveColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- Slider con numeración lateral
                  Row(
                    children: [
                      Text(
                        '1 km',
                        style: TextStyle(color: colors.distanceLabelColor),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: colors.distanceSliderActiveColor,
                            inactiveTrackColor:
                                colors.distanceSliderInactiveColor,
                            thumbColor: colors.distanceSliderThumbColor,
                          ),
                          child: Slider(
                            value: _radiusKm,
                            min: 1,
                            max: 30,
                            divisions: 29,
                            onChanged: (value) {
                              setState(() => _radiusKm = value);
                            },
                          ),
                        ),
                      ),
                      Text(
                        '30 km',
                        style: TextStyle(color: colors.distanceLabelColor),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // CATEGORÍAS
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categorías',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.categoriesTitleColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecciona categorías y subcategorías para filtrar los negocios.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.categoriesSubtitleColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: kFilterCategories.length,
                  itemBuilder: (_, index) {
                    final category = kFilterCategories[index];
                    return CategoryExpansionMolecule(
                      category: category,
                      selectedSubcategoryIds: _selectedSubcategoryIds,
                      colors: colors,
                      onToggleSubcategory: _toggleSubcategory,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // BOTÓN APLICAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgButton,
                    foregroundColor: textButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: hasAnyFilter ? _applyAndClose : null,
                  child: Text(
                    'Aplicar filtros',
                    style: TextStyle(color: textButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
