class ProductSubcategory {
  final int id;
  final String value;
  final String description;
  final String source;
  final int productCategoryId;

  ProductSubcategory({
    required this.id,
    required this.value,
    required this.description,
    required this.source,
    required this.productCategoryId,
  });

  factory ProductSubcategory.fromMap(Map<String, dynamic> json) {
    return ProductSubcategory(
      id: json['product_subcategory_id'],
      value: json['product_subcategory'],
      description: json['product_subcategory_description'],
      source: json['source'] ?? '',
      productCategoryId: json['product_category_id'],
    );
  }
  factory ProductSubcategory.empty() {
    return ProductSubcategory(
      id: 0,description: "",
      value: '',source: "",productCategoryId: -1
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductSubcategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}