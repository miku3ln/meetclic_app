class ManagerProcessMicroResult<T> {
  final bool success;
  final T? data;
  final String message;
  final String type;

  const ManagerProcessMicroResult({
    required this.success,
    this.data,
    this.message = '',
    required this.type,
  });
}