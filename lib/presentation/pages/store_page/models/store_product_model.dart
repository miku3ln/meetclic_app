class StoreProductModel {
  final int id;
  final String name;
  final String unit; // ej: "1 kg"
  final double price;
  final String origin; // ej: "Australia"
  final String imageUrl;
  final int categoryId;
  final bool isPromo;

  const StoreProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.origin,
    required this.imageUrl,
    required this.categoryId,
    this.isPromo = false,
  });
}
