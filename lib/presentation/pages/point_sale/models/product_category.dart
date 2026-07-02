import 'package:meetclic_app/presentation/pages/point_sale/models/product_subcategory.dart';

class ProductCategory {
  final int id;
  final String value;
  final String description;
  final String source;
  final List<ProductSubcategory> subcategories;

  ProductCategory({
    required this.id,
    required this.value,
    required this.description,
    required this.source,
    required this.subcategories,
  });

  factory ProductCategory.fromMap(Map<String, dynamic> json) {

    return ProductCategory(
      id: json['product_category_id'],
      value: json['product_category'],
      description: json['product_category_description'] ?? '',
      source: json['source'] ?? '',
      subcategories: (json['subcategories'] as List<dynamic>? ?? [])
          .map((e) => ProductSubcategory.fromMap(e))
          .toList(),
    );
  }


  factory ProductCategory.empty() {
    return  ProductCategory(
      id: -1,
      value: '',
      description: '',
      source: '',
      subcategories: [],
    );
  }
  /// 🔥 CLAVE
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}