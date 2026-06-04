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
class UnitMeasureModel {
  final int id;
  final String name;
  final String symbol;
  final double factorToBase;
  final bool isBase;
  final bool isDefault;
  final int decimalPrecision;
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