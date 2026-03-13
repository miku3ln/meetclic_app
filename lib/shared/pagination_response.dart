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

  const GenericListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.image,
    this.data,
  });
}