class ResultModel<T> {
  final bool success;
  final String message;
  final String type;
  final T? data;

  const ResultModel({
    required this.success,
    required this.message,
    required this.type,
    this.data,
  });

  factory ResultModel.success({required String message, T? data}) {
    return ResultModel(success: true, message: message, type: 'success', data: data);
  }

  factory ResultModel.error({required String message, required String type, T? data}) {
    return ResultModel(success: false, message: message, type: type, data: data);
  }
}
