import 'dart:io';

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

  final File image;

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