class ApiResponseViewModel {
  final String locale;
  final Map<String, List<String>> errors;

  ApiResponseViewModel({
    required this.locale,
    required this.errors,
  });

  factory ApiResponseViewModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseViewModel(
      locale: json['locale'] ?? 'es',
      errors: Map<String, List<String>>.from(json['errors']
          ?.map((key, value) => MapEntry(key, List<String>.from(value))) ?? {}),
    );
  }
}
