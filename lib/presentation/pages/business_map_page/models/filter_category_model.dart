import 'package:flutter/material.dart';

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

/// Data estática armada desde tus tablas.
/// Más adelante esto puede venir de un servicio / repo.
const List<FilterCategory> kFilterCategories = [
  // 1) Comida y Bebida
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
      FilterSubcategory(id: '11', name: 'Francesas', icon: Icons.bakery_dining),
      FilterSubcategory(id: '12', name: 'Mexicanas', icon: Icons.local_dining),
      FilterSubcategory(id: '13', name: 'Chifas', icon: Icons.rice_bowl),
      FilterSubcategory(id: '14', name: 'Fast Food', icon: Icons.fastfood),
      FilterSubcategory(id: '15', name: 'Árabe', icon: Icons.kebab_dining),
      FilterSubcategory(id: '16', name: 'Otros', icon: Icons.more_horiz),
    ],
  ),

  // 2) Ocio
  FilterCategory(
    id: '2',
    name: 'Ocio',
    icon: Icons.celebration,
    subcategories: [
      FilterSubcategory(id: '17', name: 'Parques', icon: Icons.park),
      FilterSubcategory(id: '18', name: 'Gimnasio', icon: Icons.fitness_center),
      FilterSubcategory(id: '19', name: 'Galería de Arte', icon: Icons.brush),
      FilterSubcategory(id: '20', name: 'Atracciones', icon: Icons.attractions),
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

  // 3) Comercios / Establecimientos
  FilterCategory(
    id: '3',
    name: 'Comercios / Establecimientos',
    icon: Icons.storefront,
    subcategories: [
      FilterSubcategory(id: '30', name: 'Tiendas', icon: Icons.store),
    ],
  ),

  // 4) Oficios / Servicios
  FilterCategory(
    id: '4',
    name: 'Oficios / Servicios',
    icon: Icons.handyman,
    subcategories: [
      FilterSubcategory(id: '40', name: 'Servicios varios', icon: Icons.build),
    ],
  ),

  // 5) Salud
  FilterCategory(
    id: '5',
    name: 'Salud',
    icon: Icons.local_hospital,
    subcategories: [
      FilterSubcategory(id: '50', name: 'Clínicas', icon: Icons.local_hospital),
    ],
  ),

  // 6) Construcción
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

  // 7) Textil
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

  // 8) Transporte
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
