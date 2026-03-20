import 'dart:io';

import '../../../../shared/pagination_response.dart';
import '../widgets/organisms/ps_toogle_group.dart';
import 'product_category.dart';
import 'product_subcategory.dart';


class ProductDraft {
  final String name;
  final double price;
  final double cost;

  final ProductCategory category;
  final ProductSubcategory subcategory;

  final SellType sellType;

  final double stock;
  final double lowStock;

  final String code;
  final String barcode;

  final File? image;

  ProductDraft({
    required this.name,
    required this.price,
    required this.cost,
    required this.category,
    required this.subcategory,
    required this.sellType,
    required this.stock,
    required this.lowStock,
    required this.code,
    required this.barcode,
    required this.image,
  });
}
class ProductMapper {
  ProductMapper._();

  static ProductDraft fromMap(Map<String, dynamic>? map) {
    final m = map ?? {};

    return ProductDraft(
      name: m['title']?.toString() ?? '',

      price: (m['price'] is num)
          ? (m['price'] as num).toDouble()
          : 0.0,

      cost: (m['cost'] is num)
          ? (m['cost'] as num).toDouble()
          : 0.0,

      stock: (m['stock'] is num)
          ? (m['stock'] as num).toDouble()
          : 0.0,

      lowStock: (m['lowStock'] is num)
          ? (m['lowStock'] as num).toDouble()
          : 0.0,

      code: m['code']?.toString() ?? '',
      barcode: m['barcode']?.toString() ?? '',

      /// ⚠️ AQUÍ ESTÁ LO CRÍTICO
      category: m['category'] is ProductCategory
          ? m['category']
          : ProductCategory.empty(), // 👈 debes crear esto

      subcategory: m['subcategory'] is ProductSubcategory
          ? m['subcategory']
          : ProductSubcategory.empty(),

      sellType: SellType.unit,

      image: null,
    );
  }
}




class ProductCategoryDraft {
  final String name;


  final String? image;

  ProductCategoryDraft({
    required this.name,
    required this.image,
  });
}
class ProductCategoryMapper {
  ProductCategoryMapper._();

  static ProductCategoryDraft fromMap( GenericListItem<Map<String, dynamic>>item) {
    final m = item ;

    return ProductCategoryDraft(
      name: m.title.toString() ?? '',
      image:  m.image?.toString() ?? '',
    );
  }
}