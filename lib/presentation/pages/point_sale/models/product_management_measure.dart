
import 'dart:ffi';

import '../widgets/organisms/ps_toogle_group.dart';

class ConversionModel {
  final int id;
  final double factor;
  final String conversionType;
  final String description;
  final int? productId;
  final ToUnitModel toUnit;

  ConversionModel({
    required this.id,
    required this.factor,
    required this.conversionType,
    required this.description,
    required this.productId,
    required this.toUnit,
  });

  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    return ConversionModel(
      id: json['id'],
      factor: double.parse(json['factor'].toString()),
      conversionType: json['conversion_type'],
      description: json['description'],
      productId: json['product_id'],
      toUnit: ToUnitModel.fromJson(json['to_unit']),
    );
  }
}
class ToUnitModel {
  final int id;
  final String name;
  final String symbol;

  ToUnitModel({
    required this.id,
    required this.name,
    required this.symbol,
  });

  factory ToUnitModel.fromJson(Map<String, dynamic> json) {
    return ToUnitModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
    );
  }
}
class ProductType {
  final String id;
  final String name;
  final String description;

  ProductType({
    required this.id,
    required this.name,
    required this.description

  });
}

class UnitMeasureModel {
  late final int id;
  late final String name;
  late final String symbol;
  late final double factorToBase;
  late final bool isBase;
  late final bool isDefault;
  late final int decimalPrecision;
  final List<ConversionModel> conversions;

  UnitMeasureModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.factorToBase,
    required this.isBase,
    required this.isDefault,
    required this.decimalPrecision,
    required this.conversions,
  });

  factory UnitMeasureModel.fromJson(Map<String, dynamic> json) {
    return UnitMeasureModel(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      factorToBase: double.parse(json['factor_to_base'].toString()),
      isBase: json['is_base'],
      isDefault: json['is_default'],
      decimalPrecision: json['decimal_precision'],
      conversions: (json['conversions'] as List<dynamic>)
          .map((e) => ConversionModel.fromJson(e))
          .toList(),
    );
  }
  factory UnitMeasureModel.empty() {
    return UnitMeasureModel(
      id: 0,
      name: '',
      symbol: '',
      factorToBase: 0.0,
      isBase: false,
      isDefault: false,
      decimalPrecision: 0,
      conversions: const [],
    );
  }
}
class MeasureCategoryModel {
  final int id;
  final String name;
  final String description;
  final String prefix;
  final String symbol;
  final UnitMeasureModel baseUnit;
  final List<UnitMeasureModel> units;

  MeasureCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.prefix,
    required this.symbol,
    required this.baseUnit,
    required this.units,
  });

  factory MeasureCategoryModel.fromJson(Map<String, dynamic> json) {
    return MeasureCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      prefix: json['prefix'],
      symbol: json['symbol'],
      baseUnit: UnitMeasureModel.fromJson(json['base_unit']),
      units: (json['units'] as List<dynamic>)
          .map((e) => UnitMeasureModel.fromJson(e))
          .toList(),
    );
  }
}
class StateModel<T> {
  final T id;
  final String name;
  final String description;

  const StateModel({
    required this.id,
    required this.name,
    required this.description,
  });


  @override
  bool operator ==(Object other) {

    if (identical(this, other)) {
      return true;
    }

    return other is StateModel<T> &&
        other.id == id;
  }


  @override
  int get hashCode => id.hashCode;
}
class TaxCategoryModel {
  final int id;
  final String name;
  final double taxPercentage;

  final String description;
  final int priority;


  TaxCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.taxPercentage,

  });

  factory TaxCategoryModel.fromJson(Map<String, dynamic> json) {
    return TaxCategoryModel(
      id: json['tax_id'],
      name: json['tax_percentage'].toString(),
      taxPercentage:  double.parse(json['tax_percentage'].toString()),
      description: json['tax_name'],
      priority: (json['tax_priority']),

    );
  }
  factory TaxCategoryModel.empty() {
    return TaxCategoryModel(
      id: 0,
      name: '',
      taxPercentage:  0,
      description:'',
      priority: 0,
    );
  }
}

class RecipeIngredientItem {

  final int recipeId;
  final int productId;
  final String name;
  final String code;
  final String inventoryType;
  final String productType;
  double quantityInput;
  double quantityBase;
  double conversionFactor;
  int unitInputId;
  int baseUnitMeasureId;
  UnitMeasureModel? inputUnit;
  UnitMeasureModel? baseUnit;
  String? allData;

  RecipeIngredientItem({
    required this.recipeId,
    required this.productId,
    required this.name,
    required this.code,
    required this.inventoryType,
    required this.productType,
    required this.quantityInput,
    required this.quantityBase,
    required this.conversionFactor,
    required this.unitInputId,
    required this.baseUnitMeasureId,
    this.inputUnit,
    this.baseUnit,
    this.allData,

  });
}
