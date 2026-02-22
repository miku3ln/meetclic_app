import 'package:flutter/foundation.dart';

@immutable
class PosActionItem {
  final String id;
  final String name;
  final VoidCallback onTap;
  final bool enabled;

  const PosActionItem({
    required this.id,
    required this.name,
    required this.onTap,
    this.enabled = true,
  });
}