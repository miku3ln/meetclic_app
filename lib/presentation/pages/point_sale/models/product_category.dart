class ProductCategory {
  final int id;
  final String value;
  final String description;
  final String source;

  ProductCategory({
    required this.id,
    required this.value,
    required this.description,
    required this.source,
  });

  factory ProductCategory.fromMap(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      value: json['value'],
      description: json['description'],
      source: json['source'],
    );
  }

  factory ProductCategory.empty() {
    return ProductCategory(
      id: -1,
      value: '',description: "",source: ""
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