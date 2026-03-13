class ListItemModel<T> {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String? image;
  final T? data;

  const ListItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.image,
    this.data,
  });
}