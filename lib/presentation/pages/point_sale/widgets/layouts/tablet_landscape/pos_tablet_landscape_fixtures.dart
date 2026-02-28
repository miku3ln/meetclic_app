
import '../../models/pos_action_item.dart';
import '../../models/pos_product_item.dart';

class PosTabletLandscapeFixtures {
  // -------------------------
  // (1) PRODUCT CATEGORIES (Dropdown)
  // -------------------------
  static List<PosCategoryItem> getCategoriesData() {
    return const [
      PosCategoryItem(id: 'all', value: 'Todos', description: 'Todos los productos'),
      PosCategoryItem(id: 'mains', value: 'Platos fuertes', description: 'Hamburguesas, pollo, carne'),
      PosCategoryItem(id: 'sides', value: 'Acompañamientos', description: 'Papas, arroz, ensaladas'),
      PosCategoryItem(id: 'drinks', value: 'Bebidas', description: 'Gaseosas, jugos, agua'),
      PosCategoryItem(id: 'desserts', value: 'Postres', description: 'Helados, brownie'),
      PosCategoryItem(id: 'extras', value: 'Extras', description: 'Salsas, queso, adicional'),
      PosCategoryItem(id: 'breakfast', value: 'Desayunos', description: 'Huevos, salchicha, combos desayuno'),
    ];
  }

  // -------------------------
  // (2) MENU CATEGORIES (Bottom buttons)
  // -------------------------
  static List<PosCategoryItem> getMenuCategoriesData() {
    return const [
      PosCategoryItem(id: 'all', value: 'Todo', description: 'Todo el menú'),
      PosCategoryItem(id: 'menu', value: 'Menú', description: 'Platos del día / principales'),
      PosCategoryItem(id: 'burgers', value: 'Hamburguesas', description: 'Clásicas y dobles'),
      PosCategoryItem(id: 'chicken', value: 'Pollo', description: 'Broaster / crispy'),
      PosCategoryItem(id: 'combos', value: 'Combos', description: 'Combo con papas + bebida'),
      PosCategoryItem(id: 'snacks', value: 'Snacks', description: 'Papas, alitas, nuggets'),
      PosCategoryItem(id: 'drinks', value: 'Bebidas', description: 'Frías y calientes'),
      PosCategoryItem(id: 'desserts', value: 'Postres', description: 'Dulces'),
      PosCategoryItem(id: 'breakfast', value: 'Desayunos', description: 'Huevos + arroz + salchicha'),
      PosCategoryItem(id: 'grid', value: '▦', description: 'Cambiar vista'),
    ];
  }

  // -------------------------
  // Menu Actions (tu barra inferior)
  //  - ojo: esto NO es la data, es solo UI actions
  // -------------------------
  static List<PosMenuActionItem> getMenuDataActions({
    required void Function(String id) onTap,
  }) {
    final menuCats = getMenuCategoriesData();

    // Convertimos categorías en acciones (excepto "grid" si quieres mantenerlo)
    return menuCats.map((c) {
      return PosMenuActionItem(
        id: c.id,
        value: c.value,
        description: c.description,
        onTap: () => onTap(c.id),
      );
    }).toList(growable: false);
  }

  // -------------------------
  // (3) PRODUCTS
  //  - Cada producto: productCategoryId + menuCategoryId
  // -------------------------
  static List<PosProductItem> getProductsData() {
    return const [
      // ========= MENU (platos fuertes) =========
      PosProductItem(
        id: 'prd_arroz_carne',
        name: 'Arroz con carne',
        imageUrl: 'https://picsum.photos/seed/arroz_carne/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'menu',
        taxPercentage: 0,
        unitPrice: 2.50

      ),
      PosProductItem(
        id: 'prd_arroz_pollo',
        name: 'Arroz con pollo',
        imageUrl: 'https://picsum.photos/seed/arroz_pollo/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'menu',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_arroz_huevo',
        name: 'Arroz + huevo frito',
        imageUrl: 'https://picsum.photos/seed/arroz_huevo/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'menu',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_arroz_salchicha',
        name: 'Arroz + salchicha',
        imageUrl: 'https://picsum.photos/seed/arroz_salchicha/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'menu',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= BURGERS =========
      PosProductItem(
        id: 'prd_burger_clasica',
        name: 'Hamburguesa clásica',
        imageUrl: 'https://picsum.photos/seed/burger_clasica/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'burgers',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_burger_doble',
        name: 'Hamburguesa doble',
        imageUrl: 'https://picsum.photos/seed/burger_doble/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'burgers',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_burger_pollo',
        name: 'Hamburguesa de pollo',
        imageUrl: 'https://picsum.photos/seed/burger_pollo/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'burgers',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_burger_queso',
        name: 'Hamburguesa con queso',
        imageUrl: 'https://picsum.photos/seed/burger_queso/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'burgers',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= CHICKEN =========
      PosProductItem(
        id: 'prd_pollo_crispy_2p',
        name: 'Pollo crispy (2 piezas)',
        imageUrl: 'https://picsum.photos/seed/pollo_2/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'chicken',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_pollo_crispy_3p',
        name: 'Pollo crispy (3 piezas)',
        imageUrl: 'https://picsum.photos/seed/pollo_3/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'chicken',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_alitas_6',
        name: 'Alitas (6)',
        imageUrl: 'https://picsum.photos/seed/alitas_6/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'chicken',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= SNACKS =========
      PosProductItem(
        id: 'prd_papas_med',
        name: 'Papas medianas',
        imageUrl: 'https://picsum.photos/seed/papas_med/600/600',
        productCategoryId: 'sides',
        menuCategoryId: 'snacks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_papas_gran',
        name: 'Papas grandes',
        imageUrl: 'https://picsum.photos/seed/papas_gran/600/600',
        productCategoryId: 'sides',
        menuCategoryId: 'snacks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_nuggets_6',
        name: 'Nuggets (6)',
        imageUrl: 'https://picsum.photos/seed/nuggets_6/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'snacks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_nuggets_10',
        name: 'Nuggets (10)',
        imageUrl: 'https://picsum.photos/seed/nuggets_10/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'snacks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= SIDES (acompañamientos) =========
      PosProductItem(
        id: 'prd_arroz_porcion',
        name: 'Porción de arroz',
        imageUrl: 'https://picsum.photos/seed/arroz/600/600',
        productCategoryId: 'sides',
        menuCategoryId: 'menu',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_ensalada',
        name: 'Ensalada',
        imageUrl: 'https://picsum.photos/seed/ensalada/600/600',
        productCategoryId: 'sides',
        menuCategoryId: 'menu',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= DRINKS =========
      PosProductItem(
        id: 'prd_agua',
        name: 'Agua',
        imageUrl: 'https://picsum.photos/seed/agua/600/600',
        productCategoryId: 'drinks',
        menuCategoryId: 'drinks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_cola_500',
        name: 'Cola 500ml',
        imageUrl: 'https://picsum.photos/seed/cola_500/600/600',
        productCategoryId: 'drinks',
        menuCategoryId: 'drinks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_jugo',
        name: 'Jugo natural',
        imageUrl: 'https://picsum.photos/seed/jugo/600/600',
        productCategoryId: 'drinks',
        menuCategoryId: 'drinks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_cafe',
        name: 'Café',
        imageUrl: 'https://picsum.photos/seed/cafe/600/600',
        productCategoryId: 'drinks',
        menuCategoryId: 'drinks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= DESSERTS =========
      PosProductItem(
        id: 'prd_brownie',
        name: 'Brownie',
        imageUrl: 'https://picsum.photos/seed/brownie/600/600',
        productCategoryId: 'desserts',
        menuCategoryId: 'desserts',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_helado',
        name: 'Helado',
        imageUrl: 'https://picsum.photos/seed/helado/600/600',
        productCategoryId: 'desserts',
        menuCategoryId: 'desserts',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= EXTRAS =========
      PosProductItem(
        id: 'prd_salsa_tomate',
        name: 'Salsa de tomate',
        imageUrl: 'https://picsum.photos/seed/salsa_tomate/600/600',
        productCategoryId: 'extras',
        menuCategoryId: 'snacks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_mayonesa',
        name: 'Mayonesa',
        imageUrl: 'https://picsum.photos/seed/mayo/600/600',
        productCategoryId: 'extras',
        menuCategoryId: 'snacks',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_queso_extra',
        name: 'Queso extra',
        imageUrl: 'https://picsum.photos/seed/queso_extra/600/600',
        productCategoryId: 'extras',
        menuCategoryId: 'burgers',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= BREAKFAST =========
      PosProductItem(
        id: 'prd_desayuno_huevo_arroz',
        name: 'Desayuno: huevo + arroz',
        imageUrl: 'https://picsum.photos/seed/desayuno_huevo/600/600',
        productCategoryId: 'breakfast',
        menuCategoryId: 'breakfast',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_desayuno_huevo_salchicha',
        name: 'Desayuno: huevo + salchicha',
        imageUrl: 'https://picsum.photos/seed/desayuno_salchicha/600/600',
        productCategoryId: 'breakfast',
        menuCategoryId: 'breakfast',
          taxPercentage: 16,
          unitPrice: 2.50
      ),

      // ========= COMBOS =========
      PosProductItem(
        id: 'prd_combo_burger',
        name: 'Combo Hamburguesa (papas + bebida)',
        imageUrl: 'https://picsum.photos/seed/combo_burger/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'combos',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
      PosProductItem(
        id: 'prd_combo_pollo',
        name: 'Combo Pollo (papas + bebida)',
        imageUrl: 'https://picsum.photos/seed/combo_pollo/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'combos',
          taxPercentage: 16,
          unitPrice: 2.50
      ),
    ];
  }
}