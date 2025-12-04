class SearchLocationInfoModel {
  final double latitude;
  final double longitude;

  /// Nombre de la calle o dirección corta
  final String? street;

  /// Ciudad / cantón
  final String? city;

  /// Provincia / estado
  final String? state;

  /// País (opcional)
  final String? country;

  const SearchLocationInfoModel({
    required this.latitude,
    required this.longitude,
    this.street,
    this.city,
    this.state,
    this.country,
  });
}
