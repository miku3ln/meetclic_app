
class ProductCategoryDraft {
  final String name;
  final int? id;
  final String? subtitle;
  final String? description;
  final String? code;
  final Object? image;
  final int? business_id;

  ProductCategoryDraft({
    required this.name,
    required this.image,
    required this.id,
    required this.code,
    required this.subtitle,
    required this.description,
    required this.business_id,
  });
}

class ProductCategoryMapper {
  ProductCategoryMapper._();

  static ProductCategoryDraft fromMap(Map<String, dynamic>? map) {
    final m = map ?? {};

    String nombreArchivo = "not-image-product-point-sales.png";
    var sourceManager = m['source'];
    var source = null;
    if (!sourceManager.contains(nombreArchivo)) {
      source = sourceManager;
    }
    return ProductCategoryDraft(
      name: m['value'],
      subtitle: m['subtitle'],
      description:m['description'],
      id: m['id'],
      business_id: m['business_id'],
      code: 'code',
      image: source,
    );
  }
}
