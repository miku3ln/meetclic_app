import 'package:flutter/material.dart';

import '../../state/business_filters_state.dart';

/// 🎨 Paleta específica para la hoja de filtros.
class BusinessFiltersColors {
  // HEADER
  final Color headerBackgroundColor; // Fondo de la sheet
  final Color headerTitleColor; // Texto "Filtros"
  final Color headerIconColor; // Icono de cerrar (X)
  final Color headerResetColor; // Texto "Restablecer"

  // SECCIÓN DISTANCIA
  final Color distanceTitleColor; // Texto "Distancia"
  final Color distanceSubtitleColor; // Texto descriptivo debajo
  final Color distanceSliderActiveColor; // Track activo del slider
  final Color distanceSliderInactiveColor; // Track inactivo del slider
  final Color distanceSliderThumbColor; // Thumb del slider
  final Color distanceLabelColor; // "1 km" y "30 km"

  // SECCIÓN CATEGORÍAS
  final Color categoriesTitleColor; // Texto "Categorías"
  final Color categoriesSubtitleColor; // Texto descriptivo debajo
  final Color categoryItemTextColor; // Nombre de cada categoría
  final Color categoryIconBackgroundColor; // Fondo circular del icono
  final Color categoryIconColor; // Icono dentro del círculo

  // CHECKBOX
  final Color checkboxActiveColor; // Relleno cuando está seleccionado
  final Color checkboxCheckColor; // Color de la palomita
  final Color checkboxInactiveBorderColor; // Borde cuando está desmarcado

  // BOTÓN APLICAR
  final Color applyButtonBackgroundColor;
  final Color applyButtonTextColor;
  final Color applyButtonDisabledBackgroundColor;
  final Color applyButtonDisabledTextColor;

  const BusinessFiltersColors({
    // HEADER
    required this.headerBackgroundColor,
    required this.headerTitleColor,
    required this.headerIconColor,
    required this.headerResetColor,
    // DISTANCE
    required this.distanceTitleColor,
    required this.distanceSubtitleColor,
    required this.distanceSliderActiveColor,
    required this.distanceSliderInactiveColor,
    required this.distanceSliderThumbColor,
    required this.distanceLabelColor,
    // CATEGORIES
    required this.categoriesTitleColor,
    required this.categoriesSubtitleColor,
    required this.categoryItemTextColor,
    required this.categoryIconBackgroundColor,
    required this.categoryIconColor,
    // CHECKBOX
    required this.checkboxActiveColor,
    required this.checkboxCheckColor,
    required this.checkboxInactiveBorderColor,
    // BUTTON
    required this.applyButtonBackgroundColor,
    required this.applyButtonTextColor,
    required this.applyButtonDisabledBackgroundColor,
    required this.applyButtonDisabledTextColor,
  });

  /// 🧩 Fábrica con valores por defecto basados en el Theme.
  factory BusinessFiltersColors.fromTheme(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.6);
    const headerBackgroundColor = Colors.white;

    return BusinessFiltersColors(
      // HEADER
      headerBackgroundColor: headerBackgroundColor,
      headerTitleColor: primary,
      headerIconColor: onSurface,
      headerResetColor: primary,
      // DISTANCE
      distanceTitleColor: primary,
      distanceSubtitleColor: muted,
      distanceSliderActiveColor: primary,
      distanceSliderInactiveColor: muted.withOpacity(0.3),
      distanceSliderThumbColor: primary,
      distanceLabelColor: muted,
      // CATEGORIES
      categoriesTitleColor: primary,
      categoriesSubtitleColor: muted,
      categoryItemTextColor: onSurface,
      categoryIconBackgroundColor: primary.withOpacity(0.1),
      categoryIconColor: primary,
      // CHECKBOX
      checkboxActiveColor: primary,
      checkboxCheckColor: onPrimary,
      checkboxInactiveBorderColor: muted,
      // BUTTON
      applyButtonBackgroundColor: primary,
      applyButtonTextColor: onPrimary,
      applyButtonDisabledBackgroundColor: muted.withOpacity(0.15),
      applyButtonDisabledTextColor: muted,
    );
  }
}

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

  /// IDs seleccionados de SUBCATEGORÍAS (business_subcategories.id)
  late Set<String> _selectedSubcategoryIds;

  /// Data estática armada desde tus tablas (business_categories + business_subcategories)
  /// id = id real de la BD en String
  final List<FilterCategory> _availableCategories = const [
    // ===========================
    // 1) Comida y Bebida
    // ===========================
    FilterCategory(
      id: '1',
      name: 'Comida y Bebida',
      icon: Icons.restaurant,
      subcategories: [
        FilterSubcategory(
          id: '1',
          name: 'Restaurantes',
          icon: Icons.restaurant_menu,
        ),
        FilterSubcategory(id: '2', name: 'Cafeterías', icon: Icons.local_cafe),
        FilterSubcategory(id: '3', name: 'Heladerías', icon: Icons.icecream),
        FilterSubcategory(id: '4', name: 'Repostería', icon: Icons.cake),
        FilterSubcategory(id: '5', name: 'Bar', icon: Icons.local_bar),
        FilterSubcategory(id: '6', name: 'Vegetariana', icon: Icons.spa),
        FilterSubcategory(
          id: '7',
          name: 'Carnes al Carbón',
          icon: Icons.local_fire_department,
        ),
        FilterSubcategory(id: '8', name: 'Mariscos', icon: Icons.set_meal),
        FilterSubcategory(id: '9', name: 'Italiana', icon: Icons.local_pizza),
        FilterSubcategory(id: '10', name: 'Peruana', icon: Icons.room_service),
        FilterSubcategory(
          id: '11',
          name: 'Francesas',
          icon: Icons.bakery_dining,
        ),
        FilterSubcategory(
          id: '12',
          name: 'Mexicanas',
          icon: Icons.local_dining,
        ),
        FilterSubcategory(id: '13', name: 'Chifas', icon: Icons.rice_bowl),
        FilterSubcategory(id: '14', name: 'Fast Food', icon: Icons.fastfood),
        FilterSubcategory(id: '15', name: 'Árabe', icon: Icons.kebab_dining),
        FilterSubcategory(id: '16', name: 'Otros', icon: Icons.more_horiz),
      ],
    ),

    // ===========================
    // 2) Ocio
    // ===========================
    FilterCategory(
      id: '2',
      name: 'Ocio',
      icon: Icons.celebration,
      subcategories: [
        FilterSubcategory(id: '17', name: 'Parques', icon: Icons.park),
        FilterSubcategory(
          id: '18',
          name: 'Gimnasio',
          icon: Icons.fitness_center,
        ),
        FilterSubcategory(id: '19', name: 'Galería de Arte', icon: Icons.brush),
        FilterSubcategory(
          id: '20',
          name: 'Atracciones',
          icon: Icons.attractions,
        ),
        FilterSubcategory(
          id: '21',
          name: 'Música en Vivo',
          icon: Icons.music_note,
        ),
        FilterSubcategory(id: '22', name: 'Cine', icon: Icons.movie),
        FilterSubcategory(id: '23', name: 'Museo', icon: Icons.museum),
        FilterSubcategory(id: '24', name: 'Naturaleza', icon: Icons.terrain),
        FilterSubcategory(
          id: '25',
          name: 'Bibliotecas',
          icon: Icons.local_library,
        ),
      ],
    ),

    // ===========================
    // 3) Comercios / Establecimientos
    // ===========================
    FilterCategory(
      id: '3',
      name: 'Comercios / Establecimientos',
      icon: Icons.storefront,
      subcategories: [
        // aquí podrías mapear más subcategorías de esa categoría
        FilterSubcategory(id: '30', name: 'Tiendas', icon: Icons.store),
      ],
    ),

    // ===========================
    // 4) Oficios / Servicios
    // ===========================
    FilterCategory(
      id: '4',
      name: 'Oficios / Servicios',
      icon: Icons.handyman,
      subcategories: [
        FilterSubcategory(
          id: '40',
          name: 'Servicios varios',
          icon: Icons.build,
        ),
      ],
    ),

    // ===========================
    // 5) Salud
    // ===========================
    FilterCategory(
      id: '5',
      name: 'Salud',
      icon: Icons.local_hospital,
      subcategories: [
        FilterSubcategory(
          id: '50',
          name: 'Clínicas',
          icon: Icons.local_hospital,
        ),
      ],
    ),

    // ===========================
    // 6) Construcción
    // ===========================
    FilterCategory(
      id: '6',
      name: 'Construcción',
      icon: Icons.construction,
      subcategories: [
        FilterSubcategory(
          id: '60',
          name: 'Ferreterías',
          icon: Icons.home_repair_service,
        ),
      ],
    ),

    // ===========================
    // 7) Textil
    // ===========================
    FilterCategory(
      id: '7',
      name: 'Textil',
      icon: Icons.checkroom,
      subcategories: [
        FilterSubcategory(
          id: '70',
          name: 'Ropa y Moda',
          icon: Icons.shopping_bag,
        ),
      ],
    ),

    // ===========================
    // 8) Transporte
    // ===========================
    FilterCategory(
      id: '8',
      name: 'Transporte',
      icon: Icons.directions_bus,
      subcategories: [
        FilterSubcategory(
          id: '80',
          name: 'Transporte y taxis',
          icon: Icons.local_taxi,
        ),
      ],
    ),
  ];

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
      _radiusKm = 10; // default
      _selectedSubcategoryIds.clear();
    });
  }

  void _applyAndClose() {
    final newState = widget.initialState.copyWith(
      radiusKm: _radiusKm,
      // ahora guardamos IDs de SUBCATEGORÍAS
      categoriesIds: _selectedSubcategoryIds.toList(),
    );
    Navigator.of(context).pop<BusinessFiltersState>(newState);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = widget.colors ?? BusinessFiltersColors.fromTheme(theme);

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
                        inactiveTrackColor: colors.distanceSliderInactiveColor,
                        thumbColor: colors.distanceSliderThumbColor,
                      ),
                      child: Slider(
                        value: _radiusKm,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '${_radiusKm.toStringAsFixed(0)} km',
                        onChanged: (value) {
                          setState(() {
                            _radiusKm = value;
                          });
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

              // LISTA: CATEGORÍA + SUBCATEGORÍAS (CHECKLIST)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableCategories.length,
                  itemBuilder: (_, index) {
                    final category = _availableCategories[index];

                    return ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: colors.categoryIconBackgroundColor,
                        child: Icon(
                          category.icon,
                          size: 18,
                          color: colors.categoryIconColor,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(color: colors.categoryItemTextColor),
                      ),
                      children: category.subcategories.map((sub) {
                        final selected = _selectedSubcategoryIds.contains(
                          sub.id,
                        );

                        return CheckboxListTile(
                          dense: true,
                          secondary: Icon(
                            sub.icon,
                            size: 18,
                            color: colors.categoryIconColor,
                          ),
                          title: Text(
                            sub.name,
                            style: TextStyle(
                              color: colors.categoryItemTextColor,
                            ),
                          ),
                          value: selected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedSubcategoryIds.add(sub.id);
                              } else {
                                _selectedSubcategoryIds.remove(sub.id);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: colors.checkboxActiveColor,
                          checkColor: colors.checkboxCheckColor,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // BOTÓN APLICAR
              SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (_) {
                    final hasAnyFilter =
                        _selectedSubcategoryIds.isNotEmpty || _radiusKm != 10;
                    final bgColor = hasAnyFilter
                        ? colors.applyButtonBackgroundColor
                        : colors.applyButtonDisabledBackgroundColor;
                    final textColor = hasAnyFilter
                        ? colors.applyButtonTextColor
                        : colors.applyButtonDisabledTextColor;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bgColor,
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: hasAnyFilter ? _applyAndClose : null,
                      child: Text(
                        'Aplicar filtros',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modelo de subcategoría (business_subcategories)
class FilterSubcategory {
  final String id; // id real de la BD en String
  final String name;
  final IconData icon;

  const FilterSubcategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

/// Modelo de categoría (business_categories)
class FilterCategory {
  final String id; // id real de la BD en String
  final String name;
  final IconData icon;
  final List<FilterSubcategory> subcategories;

  const FilterCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
  });
}
