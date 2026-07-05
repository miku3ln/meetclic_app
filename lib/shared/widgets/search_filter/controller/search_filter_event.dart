class SearchFilterEvent {
  final String type;
  final dynamic data;
  final DateTime createdAt;

  SearchFilterEvent({
    required this.type,
    this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}