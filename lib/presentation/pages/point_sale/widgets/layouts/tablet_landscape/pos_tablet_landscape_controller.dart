import 'package:flutter/material.dart';
import '../../models/pos_product_item.dart';


class PosTabletLandscapeController extends ChangeNotifier {
  // UI triggers
  VoidCallback? onRequestOpenShift;

  // Shift
  bool isShiftOpen = false;

  static const String kAll = 'all';
  static const String kGrid = 'grid';

  // (1) Product Categories (dropdown)
  List<PosCategoryItem> productCategories = const [];
  String? selectedProductCategoryId;

  // (2) Menu Categories (bottom bar)
  List<PosCategoryItem> menuCategories = const [];
  String? selectedMenuCategoryId;

  // Products
  List<PosProductItem> allProducts = const [];
  List<PosProductItem> products = const [];

  // (3) Search
  String query = '';

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

    _applyFilters();
    notifyListeners();
  }

  // (1) Dropdown change
  void onProductCategoryChanged(String? id) {
    if (id == null) return;
    selectedProductCategoryId = id;
    _applyFilters();
    notifyListeners();
  }

  // (2) Bottom bar tap
  void onMenuCategoryTap(String id) {
    selectedMenuCategoryId = id;
    _applyFilters();
    notifyListeners();
  }

  // (3) Search
  void onSearchChanged(String q) {
    query = q;
    _applyFilters();
    notifyListeners();
  }

  void onSearchSubmitted(String q) {
    query = q;
    _applyFilters();
    notifyListeners();
  }

  // Shift
  void onOpenShiftTap() => onRequestOpenShift?.call();

  Future<void> openShift(double initialCash) async {
    isShiftOpen = true;
    notifyListeners();
  }

  void onProductTap(PosProductItem product) {
    // add to ticket...
    notifyListeners();
  }

  // Filters (1 + 2 + 3)
  void _applyFilters() {
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
  void onSave() {
    // Guardar ticket (borrador) / guardar cambios
    // Recomendación: si no hay turno abierto, no guardes venta.
    if (!isShiftOpen) {
      debugPrint('onSave -> turno cerrado (no se puede guardar)');
      // Si quieres: pedir abrir turno
      onRequestOpenShift?.call();
      return;
    }

    debugPrint('onSave -> guardar ticket');
    // TODO: tu lógica real (persistir ticket en memoria/db)
    notifyListeners();
  }

  void onPay() {
    // Cobrar (proceso de pago)
    if (!isShiftOpen) {
      debugPrint('onPay -> turno cerrado (no se puede cobrar)');
      onRequestOpenShift?.call();
      return;
    }

    debugPrint('onPay -> cobrar');
    // TODO: abrir modal de pago / ir a pantalla de pago
    notifyListeners();
  }

}