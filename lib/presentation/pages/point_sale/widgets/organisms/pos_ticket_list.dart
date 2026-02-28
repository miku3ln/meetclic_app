// widgets/organisms/pos_ticket_list.dart
import 'package:flutter/material.dart';
import '../../theme/pos_ticket_styles.dart';
import '../models/pos_product_item.dart';
import '../organisms/pos_ticket_row.dart';
class PosTicketBody extends StatelessWidget {
  final List<PostTicketItem> items;
  final PosTicketStyles styles;

  final void Function(PostTicketItem item) onMinus;
  final void Function(PostTicketItem item) onPlus;

  final void Function(PostTicketItem item) onEdit;
  final void Function(PostTicketItem item) onDelete;

  const PosTicketBody({
    super.key,
    required this.items,
    required this.styles,
    required this.onMinus,
    required this.onPlus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: styles.listPadding,
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          Divider(height: styles.dividerHeight, color: styles.dividerColor),
      itemBuilder: (_, i) {
        final it = items[i];
        return PosTicketRow(
          item: it,
          styles: styles,
          onMinus: () => onMinus(it),
          onPlus: () => onPlus(it),
          onEdit: () => onEdit(it),
          onDelete: () => onDelete(it),
        );
      },
    );
  }
}