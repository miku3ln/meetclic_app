class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.success({
    String message = '',
    T? data,
  }) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error(String message,) {
    return ApiResponse(
      success: false,
      message: message,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}

class ProductModalEvent {
  final String type;
  final dynamic data;

  ProductModalEvent(this.type, [this.data]);
}

