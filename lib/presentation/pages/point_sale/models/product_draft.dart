import 'dart:io';

import 'package:meetclic_app/presentation/pages/point_sale/models/product_management_measure.dart';
import 'dart:convert';
import '../../../../shared/pagination_response.dart';
import '../widgets/organisms/ps_toogle_group.dart';
import 'product_category.dart';
import 'product_subcategory.dart';

class ProductDraft {
  final int? id;
  final String name;
  final double price;
  final double cost;

  final ProductCategory category;
  final ProductSubcategory subcategory;

  final MeasureType sellType;

  final double stock;
  final double lowStock;

  final String code;
  final String barcode;
  final String description;

  final File? image;
  final InventoryType inventoryType;

  final TaxCategoryModel? tax;
  UnitMeasureModel? selectedUnitMeasure;
  final String? detailsAll;

  ProductDraft({
    this.id,
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
    required this.description,
    required this.inventoryType,
    this.tax,
    this.selectedUnitMeasure,
    this.detailsAll,
  });
}

class ProductMapper {
  ProductMapper._();

  static ProductDraft fromMap(Map<String, dynamic>? map) {
    final m = map ?? {};
    final String currentTypeMeasureId = m['measure_type_management'][0]
        .toString();
    MeasureType sellType = MeasureType.unit;

    if (MeasureType.unit.id == currentTypeMeasureId) {
      sellType = MeasureType.unit;
    } else if (MeasureType.volume.id == currentTypeMeasureId) {
      sellType = MeasureType.volume;
    } else if (MeasureType.length.id == currentTypeMeasureId) {
      sellType = MeasureType.length;
    } else if (MeasureType.mass.id == currentTypeMeasureId) {
      sellType = MeasureType.mass;
    } else if (MeasureType.area.id == currentTypeMeasureId) {
      sellType = MeasureType.area;
    }
    final classification = m["classification"];
    final inventory_type = classification['inventory_type'];

    InventoryType inventoryType = InventoryType.raw;

    if (InventoryType.raw.id == inventory_type) {
      inventoryType = InventoryType.raw;
    } else if (InventoryType.processed.id == inventory_type) {
      inventoryType = InventoryType.processed;
    } else if (InventoryType.forSale.id == inventory_type) {
      inventoryType = InventoryType.forSale;
    }
    final taxCurrent = TaxCategoryModel(
      taxPercentage: 0,
      description: '',
      id: -1,
      name: '',
      priority: 0,
    );
    return ProductDraft(
      id: m['id'],
      name: m['name']?.toString() ?? '',
      detailsAll: m['details_all']?.toString() ?? '',
      price: (m['price'] is num) ? (m['price'] as num).toDouble() : 0.0,
      cost: (m['cost'] is num) ? (m['cost'] as num).toDouble() : 0.0,
      stock: (m['stock']['quantity'] is num)
          ? (m['stock']['quantity'] as num).toDouble()
          : 0.0,
      lowStock: (m['lowStock'] is num)
          ? (m['lowStock'] as num).toDouble()
          : 0.0,
      code: m['code']?.toString() ?? '',
      barcode: m['barcode']?.toString() ?? '',
      description: m['description']?.toString() ?? '',

      /// ⚠️ AQUÍ ESTÁ LO CRÍTICO
      category: ProductCategory(
        id: m['product_category_id'],
        value: m['category'],
        description: "noe",
        source: '',
      ),
      // 👈 debes crear esto
      subcategory: ProductSubcategory(
        id: m['product_subcategory_id'],
        description: "none",
        value: m['subcategory'],
        source: "",
        productCategoryId: m['product_category_id'],
      ),
      sellType: sellType,
      selectedUnitMeasure: m['selectedUnitMeasure'] as UnitMeasureModel?,
      inventoryType: inventoryType,
      tax: taxCurrent,
      image: null,
    );
  }
}

class ProductCategoryDraft {
  final String name;

  final String? image;

  ProductCategoryDraft({required this.name, required this.image});
}

class ProductCategoryMapper {
  ProductCategoryMapper._();

  static ProductCategoryDraft fromMap(
    GenericListItem<Map<String, dynamic>> item,
  ) {
    final m = item;

    return ProductCategoryDraft(
      name: m.title.toString() ?? '',
      image: m.image?.toString() ?? '',
    );
  }
}
