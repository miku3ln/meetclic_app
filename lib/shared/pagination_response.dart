class PaginatedResponse<T> {
  final int current;
  final int rowCount;
  final List<T> rows;
  final int total;

  const PaginatedResponse({
    required this.current,
    required this.rowCount,
    required this.rows,
    required this.total,
  });
}
class GenericListItem<T> {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String? image;
  final T? data;
  final String? businessId;
  final int? countData;

  const GenericListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.image,
    this.data,
    this.businessId,
    this.countData,

  });
}
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}