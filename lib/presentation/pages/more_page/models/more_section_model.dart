// more_section_model.dart
import 'more_item_model.dart';

class MoreSectionModel {
  final int id; // MoreItemSectionId.value
  final String title;
  final String description;
  final List<MoreItemModel> items;

  MoreSectionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
  });
}
