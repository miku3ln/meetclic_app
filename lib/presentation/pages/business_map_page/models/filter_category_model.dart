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
  // =====================================================
  // 1) Comida y Bebida
  // =====================================================
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
      // En la BD "Oficios" está con business_categories_id = 1
      FilterSubcategory(id: '40', name: 'Oficios', icon: Icons.handyman),
    ],
  ),

  // =====================================================
  // 2) Ocio
  // =====================================================
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
      FilterSubcategory(id: '26', name: 'Otros', icon: Icons.more_horiz),
    ],
  ),

  // =====================================================
  // 3) Comercios / Establecimientos
  // =====================================================
  FilterCategory(
    id: '3',
    name: 'Comercios / Establecimientos',
    icon: Icons.storefront,
    subcategories: [
      FilterSubcategory(
        id: '27',
        name: 'Limpieza e higiene',
        icon: Icons.cleaning_services,
      ),
      FilterSubcategory(
        id: '28',
        name: 'Estética y belleza',
        icon: Icons.face_retouching_natural,
      ),
      FilterSubcategory(id: '29', name: 'Tiendas y bazares', icon: Icons.store),
      FilterSubcategory(id: '30', name: 'Papelerías', icon: Icons.menu_book),
      FilterSubcategory(
        id: '31',
        name: 'Supermercados',
        icon: Icons.local_grocery_store,
      ),
      FilterSubcategory(id: '32', name: 'Electrodomésticos', icon: Icons.tv),
      FilterSubcategory(id: '33', name: 'Mobiliario', icon: Icons.chair_alt),
      FilterSubcategory(id: '34', name: 'Abarrotes', icon: Icons.local_mall),
      FilterSubcategory(
        id: '35',
        name: 'Motos/Bicicletas',
        icon: Icons.pedal_bike,
      ),
      FilterSubcategory(
        id: '36',
        name: 'Automotriz',
        icon: Icons.directions_car,
      ),
      FilterSubcategory(id: '37', name: 'Calzado', icon: Icons.hiking),
      FilterSubcategory(id: '38', name: 'Agricultura', icon: Icons.agriculture),
      FilterSubcategory(id: '39', name: 'Otros', icon: Icons.more_horiz),
      // Educación (viene en la BD como categoría 3)
      FilterSubcategory(id: '70', name: 'Escuelas', icon: Icons.school),
      FilterSubcategory(id: '71', name: 'Colegios', icon: Icons.apartment),
      FilterSubcategory(
        id: '72',
        name: 'Educación Inicial',
        icon: Icons.child_care,
      ),
      FilterSubcategory(
        id: '73',
        name: 'Educación Inicial 2',
        icon: Icons.child_friendly,
      ),
      FilterSubcategory(
        id: '74',
        name: 'Universidades',
        icon: Icons.account_balance,
      ),
      FilterSubcategory(
        id: '75',
        name: 'Universidad de 4 Nivel',
        icon: Icons.school_outlined,
      ),
    ],
  ),

  // =====================================================
  // 4) Oficios / Servicios
  // =====================================================
  FilterCategory(
    id: '4',
    name: 'Oficios / Servicios',
    icon: Icons.build_circle,
    subcategories: [
      FilterSubcategory(id: '41', name: 'Hospedaje', icon: Icons.hotel),
      FilterSubcategory(
        id: '42',
        name: 'Servicios financieros',
        icon: Icons.account_balance_wallet,
      ),
      FilterSubcategory(
        id: '43',
        name: 'Servicios profesionales',
        icon: Icons.work_outline,
      ),
      FilterSubcategory(
        id: '44',
        name: 'Servicios empresariales',
        icon: Icons.business_center,
      ),
      FilterSubcategory(
        id: '45',
        name: 'Logística',
        icon: Icons.local_shipping,
      ),
      FilterSubcategory(id: '46', name: 'Educación', icon: Icons.school),
      FilterSubcategory(id: '47', name: 'Otros', icon: Icons.more_horiz),
    ],
  ),

  // =====================================================
  // 5) Salud
  // =====================================================
  FilterCategory(
    id: '5',
    name: 'Salud',
    icon: Icons.medical_services,
    subcategories: [
      FilterSubcategory(
        id: '48',
        name: 'Hospitales',
        icon: Icons.local_hospital,
      ),
      FilterSubcategory(
        id: '49',
        name: 'Industria Farmacéutica',
        icon: Icons.medication,
      ),
      FilterSubcategory(
        id: '50',
        name: 'Consultorio médico',
        icon: Icons.local_hospital_outlined,
      ),
      FilterSubcategory(id: '51', name: 'Clínicas', icon: Icons.local_pharmacy),
      FilterSubcategory(id: '52', name: 'Veterinaria', icon: Icons.pets),
      FilterSubcategory(id: '53', name: 'Otros', icon: Icons.more_horiz),
    ],
  ),

  // =====================================================
  // 6) Construcción
  // =====================================================
  FilterCategory(
    id: '6',
    name: 'Construcción',
    icon: Icons.construction,
    subcategories: [
      FilterSubcategory(
        id: '54',
        name: 'Ferreterías',
        icon: Icons.home_repair_service,
      ),
      FilterSubcategory(
        id: '55',
        name: 'Materiales de construcción',
        icon: Icons.layers,
      ),
      FilterSubcategory(
        id: '56',
        name: 'Maquinaria pesada',
        icon: Icons.precision_manufacturing,
      ),
      FilterSubcategory(id: '57', name: 'Constructoras', icon: Icons.apartment),
      FilterSubcategory(id: '58', name: 'Otros', icon: Icons.more_horiz),
    ],
  ),

  // =====================================================
  // 7) Textil
  // =====================================================
  FilterCategory(
    id: '7',
    name: 'Textil',
    icon: Icons.checkroom,
    subcategories: [
      FilterSubcategory(id: '59', name: 'Empresa textil', icon: Icons.factory),
      FilterSubcategory(
        id: '60',
        name: 'Venta de ropa',
        icon: Icons.shopping_bag,
      ),
      FilterSubcategory(
        id: '61',
        name: 'Venta de telas',
        icon: Icons.inventory_2,
      ),
      FilterSubcategory(
        id: '62',
        name: 'Boutique',
        icon: Icons.store_mall_directory,
      ),
      FilterSubcategory(
        id: '63',
        name: 'Producción textil',
        icon: Icons.local_mall,
      ),
      FilterSubcategory(
        id: '64',
        name: 'Ropa y complementos',
        icon: Icons.checkroom_outlined,
      ),
      FilterSubcategory(id: '65', name: 'Otros', icon: Icons.more_horiz),
    ],
  ),

  // =====================================================
  // 8) Transporte
  // =====================================================
  FilterCategory(
    id: '8',
    name: 'Transporte',
    icon: Icons.directions_bus,
    subcategories: [
      FilterSubcategory(
        id: '66',
        name: 'Terrestre',
        icon: Icons.directions_bus_filled,
      ),
      FilterSubcategory(id: '67', name: 'Aéreo', icon: Icons.flight),
      FilterSubcategory(
        id: '68',
        name: 'Acuático',
        icon: Icons.directions_boat,
      ),
      FilterSubcategory(id: '69', name: 'Otros', icon: Icons.more_horiz),
    ],
  ),
];
