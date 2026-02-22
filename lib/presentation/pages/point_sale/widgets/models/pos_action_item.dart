import 'package:flutter/foundation.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/models/pos_product_item.dart';

@immutable
class PosMenuActionItem extends PosBaseItem {
  final VoidCallback onTap;
  final bool enabled;

  const PosMenuActionItem({
    required super.id,
    required super.value,
    super.description = '',
    required this.onTap,
    this.enabled = true,
  });
}