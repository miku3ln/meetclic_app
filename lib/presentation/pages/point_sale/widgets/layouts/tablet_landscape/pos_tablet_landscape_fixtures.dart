import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../../../domain/services/session_service.dart';
import '../../../../../../infrastructure/config/server_config.dart';
import '../../../../../../shared/models/api_response.dart';
import '../../../models/product_management_measure.dart';
import '../../models/pos_action_item.dart';
import '../../models/pos_product_item.dart';
import '../pos_main_controller.dart';

class PosTabletLandscapeFixtures {
  // -------------------------
  // (1) PRODUCT CATEGORIES (Dropdown)
  // -------------------------
  static List<PosCategoryItem> getCategoriesData(List<PosProductItem> products) {
    final Map<String, PosCategoryItem> map = {};

    for (final p in products) {
      map[p.productCategoryId] = PosCategoryItem(
        id: p.productCategoryId,
        value: p.productCategory ?? 'Sin categoría',
        description: p.productCategory ?? '',
      );
    }

    return [
      const PosCategoryItem(
        id: 'all',
        value: 'Todos',
        description: 'Todos los productos',
      ),
      ...map.values,
    ];
  }

  // -------------------------
  // (2) MENU CATEGORIES (Bottom buttons)
  // -------------------------
  static List<PosCategoryItem> getMenuCategoriesData(List<PosProductItem> products) {
    final Map<String, PosCategoryItem> map = {};
    for (final p in products) {
      map[p.menuCategoryId] = PosCategoryItem(
        id: p.menuCategoryId,
        value: p.menuCategory ?? 'Sin Subcategoria',
        description: p.menuCategoryId ?? '',
      );
    }

    return [
      const PosCategoryItem(
        id: 'all',
        value: 'Todos',
        description: 'Todos los productos',
      ),
      ...map.values,
    ];


  }

  // -------------------------
  // Menu Actions (tu barra inferior)
  //  - ojo: esto NO es la data, es solo UI actions
  // -------------------------
  static List<PosMenuActionItem> getMenuDataActions({
    required void Function(String id) onTap,
    required PosMainController controller
  }) {


    final menuCats = getMenuCategoriesData(controller.browser.allProducts);

    // Convertimos categorías en acciones (excepto "grid" si quieres mantenerlo)
    return menuCats
        .map((c) {
          return PosMenuActionItem(
            id: c.id,
            value: c.value,
            description: c.description,
            onTap: () => onTap(c.id),
          );
        })
        .toList(growable: false);
  }

  // -------------------------
  // (3) PRODUCTS
  //  - Cada producto: productCategoryId + menuCategoryId
  // -------------------------
  static Future<List<PosProductItem>> getProductsData() async {
    return PosMockData.getProductsData();

    /*return const [
      // ========= MENU (platos fuertes) =========
      PosProductItem(
        id: 'prd_arroz_carne',
        name: 'Arroz con carne',
        imageUrl: 'https://picsum.photos/seed/arroz_carne/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'menu',
        taxPercentage: 0,
        unitPrice: 2.50,

      ),
      PosProductItem(
        id: 'prd_arroz_pollo',
        name: 'Arroz con pollo',
        imageUrl: 'https://picsum.photos/seed/arroz_pollo/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'menu',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_arroz_huevo',
        name: 'Arroz + huevo frito',
        imageUrl: 'https://picsum.photos/seed/arroz_huevo/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'menu',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_arroz_salchicha',
        name: 'Arroz + salchicha',
        imageUrl: 'https://picsum.photos/seed/arroz_salchicha/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'menu',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= BURGERS =========
      PosProductItem(
        id: 'prd_burger_clasica',
        name: 'Hamburguesa clásica',
        imageUrl: 'https://picsum.photos/seed/burger_clasica/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'burgers',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_burger_doble',
        name: 'Hamburguesa doble',
        imageUrl: 'https://picsum.photos/seed/burger_doble/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'burgers',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_burger_pollo',
        name: 'Hamburguesa de pollo',
        imageUrl: 'https://picsum.photos/seed/burger_pollo/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'burgers',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_burger_queso',
        name: 'Hamburguesa con queso',
        imageUrl: 'https://picsum.photos/seed/burger_queso/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'burgers',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= CHICKEN =========
      PosProductItem(
        id: 'prd_pollo_crispy_2p',
        name: 'Pollo crispy (2 piezas)',
        imageUrl: 'https://picsum.photos/seed/pollo_2/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'chicken',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_pollo_crispy_3p',
        name: 'Pollo crispy (3 piezas)',
        imageUrl: 'https://picsum.photos/seed/pollo_3/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'chicken',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_alitas_6',
        name: 'Alitas (6)',
        imageUrl: 'https://picsum.photos/seed/alitas_6/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'chicken',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= SNACKS =========
      PosProductItem(
        id: 'prd_papas_med',
        name: 'Papas medianas',
        imageUrl: 'https://picsum.photos/seed/papas_med/600/600',
        productCategoryId: 'sides',
        menuCategoryId: 'snacks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_papas_gran',
        name: 'Papas grandes',
        imageUrl: 'https://picsum.photos/seed/papas_gran/600/600',
        productCategoryId: 'sides',
        menuCategoryId: 'snacks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_nuggets_6',
        name: 'Nuggets (6)',
        imageUrl: 'https://picsum.photos/seed/nuggets_6/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'snacks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_nuggets_10',
        name: 'Nuggets (10)',
        imageUrl: 'https://picsum.photos/seed/nuggets_10/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'snacks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= SIDES (acompañamientos) =========
      PosProductItem(
        id: 'prd_arroz_porcion',
        name: 'Porción de arroz',
        imageUrl: 'https://picsum.photos/seed/arroz/600/600',
        productCategoryId: 'sides',
        menuCategoryId: 'menu',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_ensalada',
        name: 'Ensalada',
        imageUrl: 'https://picsum.photos/seed/ensalada/600/600',
        productCategoryId: 'sides',
        menuCategoryId: 'menu',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= DRINKS =========
      PosProductItem(
        id: 'prd_agua',
        name: 'Agua',
        imageUrl: 'https://picsum.photos/seed/agua/600/600',
        productCategoryId: 'drinks',
        menuCategoryId: 'drinks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_cola_500',
        name: 'Cola 500ml',
        imageUrl: 'https://picsum.photos/seed/cola_500/600/600',
        productCategoryId: 'drinks',
        menuCategoryId: 'drinks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_jugo',
        name: 'Jugo natural',
        imageUrl: 'https://picsum.photos/seed/jugo/600/600',
        productCategoryId: 'drinks',
        menuCategoryId: 'drinks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_cafe',
        name: 'Café',
        imageUrl: 'https://picsum.photos/seed/cafe/600/600',
        productCategoryId: 'drinks',
        menuCategoryId: 'drinks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= DESSERTS =========
      PosProductItem(
        id: 'prd_brownie',
        name: 'Brownie',
        imageUrl: 'https://picsum.photos/seed/brownie/600/600',
        productCategoryId: 'desserts',
        menuCategoryId: 'desserts',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_helado',
        name: 'Helado',
        imageUrl: 'https://picsum.photos/seed/helado/600/600',
        productCategoryId: 'desserts',
        menuCategoryId: 'desserts',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= EXTRAS =========
      PosProductItem(
        id: 'prd_salsa_tomate',
        name: 'Salsa de tomate',
        imageUrl: 'https://picsum.photos/seed/salsa_tomate/600/600',
        productCategoryId: 'extras',
        menuCategoryId: 'snacks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_mayonesa',
        name: 'Mayonesa',
        imageUrl: 'https://picsum.photos/seed/mayo/600/600',
        productCategoryId: 'extras',
        menuCategoryId: 'snacks',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_queso_extra',
        name: 'Queso extra',
        imageUrl: 'https://picsum.photos/seed/queso_extra/600/600',
        productCategoryId: 'extras',
        menuCategoryId: 'burgers',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= BREAKFAST =========
      PosProductItem(
        id: 'prd_desayuno_huevo_arroz',
        name: 'Desayuno: huevo + arroz',
        imageUrl: 'https://picsum.photos/seed/desayuno_huevo/600/600',
        productCategoryId: 'breakfast',
        menuCategoryId: 'breakfast',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_desayuno_huevo_salchicha',
        name: 'Desayuno: huevo + salchicha',
        imageUrl: 'https://picsum.photos/seed/desayuno_salchicha/600/600',
        productCategoryId: 'breakfast',
        menuCategoryId: 'breakfast',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),

      // ========= COMBOS =========
      PosProductItem(
        id: 'prd_combo_burger',
        name: 'Combo Hamburguesa (papas + bebida)',
        imageUrl: 'https://picsum.photos/seed/combo_burger/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'combos',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
      PosProductItem(
        id: 'prd_combo_pollo',
        name: 'Combo Pollo (papas + bebida)',
        imageUrl: 'https://picsum.photos/seed/combo_pollo/600/600',
        productCategoryId: 'mains',
        menuCategoryId: 'combos',
        taxPercentage: 16,
        unitPrice: 2.50,
      ),
    ];*/
  }

  static List<PosCoupon> getCouponsData() {
    return [
      /// 🍔 BURGERS
      PosCoupon(
        id: 1,
        code: 'BURGER10',
        name: '10% Burger',
        discount: 10,
        productId: 'prd_burger_clasica',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      PosCoupon(
        id: 2,
        code: 'BURGER20',
        name: '20% Burger',
        discount: 20,
        productId: 'prd_burger_doble',
        expiresAt: DateTime.now().add(const Duration(days: 15)),
      ),
      PosCoupon(
        id: 3,
        code: 'CHEESE5',
        name: '0.5 Queso',
        discount: 0.5,
        productId: 'prd_burger_queso',
      ),
      PosCoupon(
        id: 4,
        code: 'POLLOBURGER',
        name: '15% Pollo Burger',
        discount: 15,
        productId: 'prd_burger_pollo',
      ),

      /// 🍗 POLLO
      PosCoupon(
        id: 5,
        code: 'POLLO10',
        name: '10% Pollo',
        discount: 10,
        productId: 'prd_pollo_crispy_2p',
      ),
      PosCoupon(
        id: 6,
        code: 'POLLO3P',
        name: '1 OFF Pollo 3p',
        discount: 1,
        productId: 'prd_pollo_crispy_3p',
      ),
      PosCoupon(
        id: 7,
        code: 'ALITAS20',
        name: '20% Alitas',
        discount: 20,
        productId: 'prd_alitas_6',
      ),

      /// 🍟 SNACKS
      PosCoupon(
        id: 8,
        code: 'PAPAS10',
        name: '10% Papas',
        discount: 10,
        productId: 'prd_papas_med',
      ),
      PosCoupon(
        id: 9,
        code: 'PAPASGRAND',
        name: '1 Papas grandes',
        discount: 1,
        productId: 'prd_papas_gran',
      ),
      PosCoupon(
        id: 10,
        code: 'NUGGETS5',
        name: '0.5 Nuggets',
        discount: 0.5,
        productId: 'prd_nuggets_6',
      ),
      PosCoupon(
        id: 11,
        code: 'NUGGETS10',
        name: '10% Nuggets',
        discount: 10,
        productId: 'prd_nuggets_10',
      ),

      /// 🥤 BEBIDAS
      PosCoupon(
        id: 12,
        code: 'AGUAFREE',
        name: '1 Agua',
        discount: 1,
        productId: 'prd_agua',
      ),
      PosCoupon(
        id: 13,
        code: 'COLA10',
        name: '10% Cola',
        discount: 10,
        productId: 'prd_cola_500',
      ),
      PosCoupon(
        id: 14,
        code: 'JUGO1',
        name: '1 Jugo',
        discount: 1,
        productId: 'prd_jugo',
      ),
      PosCoupon(
        id: 15,
        code: 'CAFE20',
        name: '20% Café',
        discount: 20,
        productId: 'prd_cafe',
      ),

      /// 🍰 POSTRES
      PosCoupon(
        id: 16,
        code: 'BROWNIE10',
        name: '10% Brownie',
        discount: 10,
        productId: 'prd_brownie',
      ),
      PosCoupon(
        id: 17,
        code: 'HELADO2',
        name: '2 Helado',
        discount: 2,
        productId: 'prd_helado',
      ),

      /// 🍚 MENU
      PosCoupon(
        id: 18,
        code: 'ARROZ5',
        name: '5% Arroz carne',
        discount: 5,
        productId: 'prd_arroz_carne',
      ),
      PosCoupon(
        id: 19,
        code: 'POLLOARROZ',
        name: '10% Arroz pollo',
        discount: 10,
        productId: 'prd_arroz_pollo',
      ),
      PosCoupon(
        id: 20,
        code: 'HUEVOFREE',
        name: '1 Huevo',
        discount: 1,
        productId: 'prd_arroz_huevo',
      ),
      PosCoupon(
        id: 21,
        code: 'SALCHICHA',
        name: '10% Salchicha',
        discount: 10,
        productId: 'prd_arroz_salchicha',
      ),

      /// 🧀 EXTRAS
      PosCoupon(
        id: 22,
        code: 'SALSAFREE',
        name: '0.5 Salsa',
        discount: 0.5,
        productId: 'prd_salsa_tomate',
      ),
      PosCoupon(
        id: 23,
        code: 'MAYO10',
        name: '10% Mayonesa',
        discount: 10,
        productId: 'prd_mayonesa',
      ),
      PosCoupon(
        id: 24,
        code: 'QUESO2',
        name: '2 Queso extra',
        discount: 2,
        productId: 'prd_queso_extra',
      ),

      /// 🍳 DESAYUNO
      PosCoupon(
        id: 25,
        code: 'DESAYUNO5',
        name: '5% Desayuno',
        discount: 5,
        productId: 'prd_desayuno_huevo_arroz',
      ),
      PosCoupon(
        id: 26,
        code: 'DESAYUNO10',
        name: '10% Desayuno',
        discount: 10,
        productId: 'prd_desayuno_huevo_salchicha',
      ),

      /// 🍔 COMBOS
      PosCoupon(
        id: 27,
        code: 'COMBO10',
        name: '10% Combo Burger',
        discount: 10,
        productId: 'prd_combo_burger',
      ),
      PosCoupon(
        id: 28,
        code: 'COMBO20',
        name: '20% Combo Pollo',
        discount: 20,
        productId: 'prd_combo_pollo',
      ),

      /// 🔥 GENERALES (repetidos distintos valores)
      PosCoupon(
        id: 29,
        code: 'BURGER5',
        name: '5% Burger',
        discount: 5,
        productId: 'prd_burger_clasica',
      ),
      PosCoupon(
        id: 30,
        code: 'BURGER30',
        name: '30% Burger',
        discount: 30,
        productId: 'prd_burger_doble',
      ),
      PosCoupon(
        id: 31,
        code: 'PAPAS5',
        name: '5% Papas',
        discount: 5,
        productId: 'prd_papas_med',
      ),
      PosCoupon(
        id: 32,
        code: 'NUGGETS20',
        name: '20% Nuggets',
        discount: 20,
        productId: 'prd_nuggets_10',
      ),

      /// 🔥 MÁS VARIADOS
      PosCoupon(
        id: 33,
        code: 'COLA5',
        name: '5% Cola',
        discount: 5,
        productId: 'prd_cola_500',
      ),
      PosCoupon(
        id: 34,
        code: 'CAFE5',
        name: '5% Café',
        discount: 5,
        productId: 'prd_cafe',
      ),
      PosCoupon(
        id: 35,
        code: 'HELADO10',
        name: '10% Helado',
        discount: 10,
        productId: 'prd_helado',
      ),
      PosCoupon(
        id: 36,
        code: 'BROWNIE5',
        name: '5% Brownie',
        discount: 5,
        productId: 'prd_brownie',
      ),

      /// ⚠️ EXPIRADOS
      PosCoupon(
        id: 37,
        code: 'OLD10',
        name: 'Expirado 10%',
        discount: 10,
        productId: 'prd_burger_clasica',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PosCoupon(
        id: 38,
        code: 'OLD20',
        name: 'Expirado 20%',
        discount: 20,
        productId: 'prd_combo_burger',
        expiresAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PosCoupon(
        id: 39,
        code: 'OLD5',
        name: 'Expirado 5%',
        discount: 5,
        productId: 'prd_papas_med',
        expiresAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      PosCoupon(
        id: 40,
        code: 'OLD50',
        name: 'Expirado 50%',
        discount: 50,
        productId: 'prd_burger_doble',
        expiresAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}

abstract class ProductRepository {
  Future<List<PosProductItem>> getProducts();
}

class ProductRemoteDataSource {
  Future<Map<String, dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse('${ServerConfig.baseUrl}/products-sales'),
      headers: {
        'Authorization': 'Bearer TU_TOKEN',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error API');
    }

    return jsonDecode(response.body);
  }
}

class ProductMapperOther {
  static PosProductItem fromJson(Map<String, dynamic> json) {
    return PosProductItem(
      id: json['id'].toString(),
      name: json['name'],
      imageUrl: json['source'],
      code: json['code'] ,
      type: json['type'] ,

      productCategoryId: json['product_category_id'].toString(),
      menuCategoryId: json['product_subcategory_id'].toString(),
      stock: (json['stock']['quantity'] ?? 0).toDouble(),
      unit: json['stock']['unit'] ?? 'u',
      unitPrice: 55,
      taxPercentage: 0,
    );
  }
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;

  ProductRepositoryImpl(this.remote);

  @override
  Future<List<PosProductItem>> getProducts() async {
    final data = await remote.getProducts();

    final List rows = data['data']['rows'];

    return rows.map((e) => ProductMapperOther.fromJson(e)).toList();
  }
}

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<PosProductItem>> call() {
    return repository.getProducts();
  }
}

class ProductController extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;

  List<PosProductItem> products = [];
  bool loading = false;

  ProductController(this.getProductsUseCase);

  Future<void> loadProducts() async {
    loading = true;
    notifyListeners();

    try {
      products = await getProductsUseCase();
    } catch (e) {
      print(e);
    }

    loading = false;
    notifyListeners();
  }
}

class PosMockData {
  static Future<List<PosProductItem>> getProductsData() async {
    final token = SessionService().apiToken;
final businessId=SessionService().businessId;
    final uri = Uri.parse('${ServerConfig.baseUrl}/pointsales/products-sales')//POS-PRODUCTS -INIT-ONE
        .replace(
          queryParameters: {
            'current': '1',
            'rowCount': '-1',
            'searchPhrase': '',
            'business_id': businessId,
            'grid_id': '#grid-registers-grid',
          },
        );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${token!}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {

      List<PosProductItem> result = [];
      return result;
    }
    final data = jsonDecode(response.body);
    final List rows = data['rows'];
    // 🔥 aquí haces el mapper DIRECTO
    return rows.map<PosProductItem>((json) {
      final stock = json['stock'] ?? {};
      final taxData = json['tax'] ?? {};
      final priceData = json['price'] ?? {};

      return PosProductItem(
        id: json['id'].toString(),
        name: json['name'],
        imageUrl: json['source'],
        productCategoryId: json['product_category_id'].toString(),
        menuCategoryId: json['product_subcategory_id'].toString(),
        menuCategory: json['subcategory'].toString(),
        productCategory: json['category'].toString(),
        type: json['type'].toString(),
        code: json['code'].toString(),
        taxPercentage: double.tryParse(taxData['value_percentage'] ?.toString() ?? '0') ?? 0,
        unitPrice: double.tryParse(priceData['pv']?.toString() ?? '0') ?? 0,
        // 👉 si agregas estos campos al modelo
        stock: (stock['quantity'] ?? 0).toDouble(),
        unit: stock['unit'] ?? 'u',
      );
    }).toList();
  }
  static Future<List<MeasureCategoryModel>> getCatalogMeasureData() async {
    final token = SessionService().apiToken;
    final businessId = SessionService().businessId;

    final uri = Uri.parse(
      '${ServerConfig.baseUrl}/pointsales/catalog-measure',
    ).replace(
      queryParameters: {
        'business_id': businessId,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => MeasureCategoryModel.fromJson(e))
        .toList();
  }
  static Future<List<TaxCategoryModel>> getCatalogTaxData() async {
    final token = SessionService().apiToken;
    final businessId = SessionService().businessId;

    final uri = Uri.parse(
      '${ServerConfig.baseUrl}/pointsales/catalog-tax',
    ).replace(
      queryParameters: {
        'business_id': businessId,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => TaxCategoryModel.fromJson(e))
        .toList();
  }
}

class ProductCreateRequest {
  final Map<String, dynamic> product;
  final Map<String, dynamic> businessByProducts;
  final Map<String, dynamic> productInventory;
  final Map<String, dynamic> productSellConfig;
  final Map<String, dynamic> inventoryMovement;

  const ProductCreateRequest({
    required this.product,
    required this.businessByProducts,
    required this.productInventory,
    required this.productSellConfig,
    required this.inventoryMovement,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'business_by_products': businessByProducts,
      'product_inventory': productInventory,
      'product_sell_config': productSellConfig,
      'inventory_movement': inventoryMovement,
    };
  }
}
class ProductApiError {
  final String? table;
  final Map<String, List<String>> errors;

  ProductApiError({
    this.table,
    required this.errors,
  });

  factory ProductApiError.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProductApiError(
      table: json['table'],
      errors: (json['errors'] as Map<String, dynamic>? ?? {})
          .map(
            (k, v) => MapEntry(
          k,
          List<String>.from(v),
        ),
      ),
    );
  }

  String get firstError {
    if (errors.isEmpty) return '';

    final firstField = errors.values.first;

    if (firstField.isEmpty) return '';

    return firstField.first;
  }
}
class ProductDataUtil {
  static Future<ApiResponse<Map<String, dynamic>>> createProduct(
      Map<String, dynamic> payload,
      ) async {
    try {
      final token = SessionService().apiToken;

      final response = await http.post(
        Uri.parse(
          '${ServerConfig.baseUrl}/pointsales/product-type-save',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return ApiResponse.success(
          message: body['message'] ?? 'Operación realizada correctamente',
          data: body,
        );
      }

      String message = 'Error desconocido';

      try {
        final errorRaw = body['error']?['message'];

        if (errorRaw != null) {
          final errorJson =
          jsonDecode(errorRaw) as Map<String, dynamic>;

          final table = errorJson['table'];

          final errors =
              errorJson['errors'] as Map<String, dynamic>? ?? {};

          if (errors.isNotEmpty) {
            final field = errors.keys.first;
            final fieldErrors =
            List<String>.from(errors[field]);

            message =
            '[$table] ${fieldErrors.first}';
          }
        }
      } catch (_) {
        message = body['error']?['message'] ??
            body['message'] ??
            'Error desconocido';
      }

      return ApiResponse.error(message);
    } catch (e) {
      return ApiResponse.error(
        e.toString(),
      );
    }
  }
}