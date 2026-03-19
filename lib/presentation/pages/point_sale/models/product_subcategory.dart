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
      id: json['id'],
      value: json['value'],
      description: json['description'],
      source: json['source'],
      productCategoryId: json['product_category_id'],
    );
  }
}