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

  final Object? image;
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
    final String currentTypeMeasureId = m['measure_type_management']['id']
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
    double price = double.parse(m['price']['pv']);
    double cost = double.parse(m['price']['pc']);
    double stock = (m['stock']['quantity'] as num).toDouble();
    double lowStock = (m['lowStock'] is num)
        ? (m['lowStock'] as num).toDouble()
        : 0.0;
    String nombreArchivo = "not-image-product-point-sales.png";
    var sourceManager = m['source'];
    var source = null;
    if (!sourceManager.contains(nombreArchivo)) {
      source = sourceManager;
    }

    final details_all = m['details_all'];
    final details = jsonDecode(details_all);
    final inventoryInitial = details['inventory_initial'];
    final unitInput = inventoryInitial['unit_input'];
    final selectedUnitMeasure = UnitMeasureModel(
      id: unitInput['id'],
      name: unitInput['name'],
      symbol: unitInput['symbol'],
      factorToBase: (unitInput['factor_to_base'] as num).toDouble(),
      isBase: unitInput['is_base'] == 1,
      isDefault: unitInput['measure_unit_config']['is_default'] == 1,
      decimalPrecision: unitInput['decimal_precision'],
      conversions: [],
    );

    return ProductDraft(
      id: m['id'],
      name: m['name']?.toString() ?? '',
      detailsAll: details_all?.toString() ?? '',
      price: price,
      cost: cost,
      stock: stock,
      lowStock: lowStock,
      code: m['code']?.toString() ?? '',
      barcode: m['barcode']?.toString() ?? '',
      description: m['description']?.toString() ?? '',

      /// ⚠️ AQUÍ ESTÁ LO CRÍTICO
      category: ProductCategory(
        id: m['product_category_id'],
        value: m['category'],
        description: "noe",
        source: '',
        subcategories: [],
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
      selectedUnitMeasure: selectedUnitMeasure,
      inventoryType: inventoryType,
      tax: taxCurrent,
      image: source,
    );
  }
}

class MeasureDataResult {
  final MeasureCategoryModel measureCategory;
  final List<UnitMeasureModel> units;

  MeasureDataResult({required this.measureCategory, required this.units});
}

MeasureDataResult getDataSubMeasureByMeasure(
  List<MeasureCategoryModel> listMeasureCategory,
  MeasureType type,
) {
  try {
    final resultSet = listMeasureCategory.firstWhere(
      (e) => e.id.toString() == type.id,
    );

    final unitsWithConversions = resultSet.units
        .where((unit) => unit.conversions.isNotEmpty)
        .toList();

    return MeasureDataResult(
      measureCategory: resultSet,
      units: unitsWithConversions,
    );
  } catch (e, stackTrace) {
    return MeasureDataResult(
      measureCategory: MeasureCategoryModel(
        id: 0,
        name: '',
        units: [],
        description: '',
        prefix: '',
        symbol: '',
        baseUnit: UnitMeasureModel.empty(),
      ),
      units: [],
    );
  }
}
