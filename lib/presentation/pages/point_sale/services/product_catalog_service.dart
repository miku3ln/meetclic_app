import '../models/product_category.dart';
import '../models/product_subcategory.dart';

class ProductCatalogService {
  Future<List<ProductCategory>> getCategories() async {
    /// mock
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      ProductCategory(id: 1, value: "Bebidas", description: "", source: ""),
      ProductCategory(id: 2, value: "Comida", description: "", source: ""),
    ];
  }

  Future<List<ProductSubcategory>> getSubcategories(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final all = [
      ProductSubcategory(
          id: 1,
          value: "Gaseosas",
          description: "",
          source: "",
          productCategoryId: 1),
      ProductSubcategory(
          id: 2,
          value: "Jugos",
          description: "",
          source: "",
          productCategoryId: 1),
      ProductSubcategory(
          id: 3,
          value: "Hamburguesas",
          description: "",
          source: "",
          productCategoryId: 2),
    ];

    return all.where((e) => e.productCategoryId == categoryId).toList();
  }
}