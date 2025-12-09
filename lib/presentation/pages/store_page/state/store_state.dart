import '../models/store_category_model.dart';
import '../models/store_product_model.dart';

class StoreState {
  final List<StoreCategoryModel> categories;
  final List<StoreProductModel> products;
  final int selectedCategoryId;

  const StoreState({
    required this.categories,
    required this.products,
    required this.selectedCategoryId,
  });

  factory StoreState.initial() =>
      const StoreState(categories: [], products: [], selectedCategoryId: 0);

  StoreState copyWith({
    List<StoreCategoryModel>? categories,
    List<StoreProductModel>? products,
    int? selectedCategoryId,
  }) {
    return StoreState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  /// Productos filtrados por categoría
  List<StoreProductModel> get filteredProducts {
    if (selectedCategoryId == 0) return products;
    return products
        .where((p) => p.categoryId == selectedCategoryId || p.isPromo)
        .toList();
  }
}
