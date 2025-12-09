// more_item_model.dart
import 'package:flutter/material.dart';

class MoreItemModel {
  final int id; // MoreItemProcessId.value
  final String title;
  final String description;
  final IconData icon;

  MoreItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
