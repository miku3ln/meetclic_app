// widgets/organisms/pos_ticket_row.dart
import 'package:flutter/material.dart';
import '../../theme/pos_ticket_styles.dart';
import '../../models/pos_payment_method.dart'; // (no usado)

import '../atoms/pos_avatar_thumb.dart';
import '../models/pos_product_item.dart';
import '../molecules/pos_ticket_item_actions.dart';
import '../molecules/pos_ticket_item_meta.dart';

// usa tu modelo real:
import '../../models/pos_payment_method.dart'; // ignora si no aplica
// Recomendado: mueve PostTicketItem a /models/post_ticket_item.dart
// aquí lo uso como lo tienes:
import '../../models/pos_payment_method.dart' show PostTicketItem;

class PosTicketRow extends StatelessWidget {
  final PostTicketItem item;
  final PosTicketStyles styles;

  final VoidCallback onMinus;
  final VoidCallback onPlus;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PosTicketRow({
    super.key,
    required this.item,
    required this.styles,
    required this.onMinus,
    required this.onPlus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.productItem;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: styles.rowVerticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PosAvatarThumb(
            imageUrl: p.imageUrl,
            size: styles.leftThumbSize,
            radius: styles.leftThumbRadius,
            fallback: const Color(0xFFF2F5FA),
          ),
          SizedBox(width: styles.rowGap),
          PosTicketItemMeta(
            title: p.name,
            subtitle: item.description ?? '',
            ivaPct: p.taxPercentage,
            total: item.total,
            styles: styles,
          ),
          const SizedBox(width: 12),
          PosTicketItemActions(
            styles: styles,
            onEdit: onEdit,
            onDelete: onDelete,
            unitPrice: item.unitPrice,
            qty: item.amount,
            onMinus: onMinus,
            onPlus: onPlus,
          ),
        ],
      ),
    );
  }
}