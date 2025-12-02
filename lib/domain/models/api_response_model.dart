class ApiResponseModel<T> {
  final int type;
  final bool success;
  final String message;
  final T data;  // Siempre requerido

  ApiResponseModel({
    required this.type,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponseModel.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromDataJson) {
    var type = json['type'] ?? 0;
    var success = json['success'] ?? false;
    var message = json['message'] ?? '';
    T data = fromDataJson(json['data']);
    return ApiResponseModel<T>(
      type: type,
      success: success,
      message: message,
      data: data,
    );
  }

  factory ApiResponseModel.error(String message, T emptyData) {
    return ApiResponseModel<T>(
      type: 0,
      success: false,
      message: message,
      data: emptyData,   // Siempre un valor no-nulo
    );
  }

  bool get isError => !success;
  bool get isSuccess => success;
}
