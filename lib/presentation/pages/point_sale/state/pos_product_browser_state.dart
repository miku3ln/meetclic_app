import 'package:flutter/cupertino.dart';

import '../widgets/models/pos_product_item.dart';

class PosProductBrowserState extends ChangeNotifier {
  static const String kAll = 'all';
  static const String kGrid = 'grid';

  List<PosCategoryItem> productCategories = const [];
  String? selectedProductCategoryId;

  List<PosCategoryItem> menuCategories = const [];
  String? selectedMenuCategoryId;

  List<PosProductItem> allProducts = const [];
  List<PosProductItem> products = const [];

  String query = '';
  bool loadingData = true;
  void setLoadingData(bool value) {
    loadingData = value;
    notifyListeners();
  }
  void init({
    required List<PosProductItem> initialProducts,
    required List<PosCategoryItem> initialProductCategories,
    required List<PosCategoryItem> initialMenuCategories,
    String? initialSelectedProductCategoryId,
    String? initialSelectedMenuCategoryId,
  }) {
    allProducts = initialProducts;
    productCategories = initialProductCategories;
    menuCategories = initialMenuCategories;

    selectedProductCategoryId =
        initialSelectedProductCategoryId ??
        (productCategories.isNotEmpty ? productCategories.first.id : null);

    selectedMenuCategoryId =
        initialSelectedMenuCategoryId ??
        (menuCategories.isNotEmpty ? menuCategories.first.id : null);

    applyFilters();
    notifyListeners();
  }

  void onProductCategoryChanged(String? id) {
    if (id == null) return;
    selectedProductCategoryId = id;
    applyFilters();
    notifyListeners();
  }

  void onMenuCategoryTap(String id) {
    selectedMenuCategoryId = id;
    applyFilters();
    notifyListeners();
  }

  void onSearchChanged(String q) {
    query = q;
    applyFilters();
    notifyListeners();
  }

  void applyFilters() {
    final q = query.trim().toLowerCase();
    Iterable<PosProductItem> result = allProducts;

    final pc = selectedProductCategoryId;
    if (pc != null && pc != kAll) {
      result = result.where((p) => p.productCategoryId == pc);
    }

    final mc = selectedMenuCategoryId;
    if (mc != null && mc != kAll && mc != kGrid) {
      result = result.where((p) => p.menuCategoryId == mc);
    }

    if (q.isNotEmpty) {
      result = result.where((p) => p.name.toLowerCase().contains(q));
    }

    products = result.toList(growable: false);
  }

  void onSearchSubmitted(String q) {
    query = q;
    applyFilters();
    notifyListeners();
  }
}
