class ApiDataModel {
  final String locale;
  final Map<String, List<String>> errors;

  ApiDataModel({required this.locale, required this.errors});

  factory ApiDataModel.fromJson(Map<String, dynamic> json) {
    final errors = <String, List<String>>{};
    (json['errors'] as Map<String, dynamic>?)?.forEach((key, value) {
      errors[key] = List<String>.from(value);
    });
    return ApiDataModel(
      locale: json['locale'] ?? 'es',
      errors: errors,
    );
  }
}