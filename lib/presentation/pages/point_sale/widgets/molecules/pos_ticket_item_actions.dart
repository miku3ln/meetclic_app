
import 'package:flutter/material.dart';
import '../../theme/pos_ticket_styles.dart';
import '../atoms/pos_icon_square_button.dart';
import '../atoms/pos_money_pill.dart';
import '../atoms/pos_qty_stepper.dart';

class PosTicketItemActions extends StatelessWidget {
  final PosTicketStyles styles;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final double unitPrice; // pill
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const PosTicketItemActions({
    super.key,
    required this.styles,
    required this.onEdit,
    required this.onDelete,
    required this.unitPrice,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: styles.rightColumnWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PosIconSquareButton(
                icon: Icons.edit_outlined,
                onTap: onEdit,
                size: styles.iconButtonSize,
                radius: styles.iconButtonRadius,
                bg: styles.iconBtnBg,
                border: styles.iconBtnBorder,
              ),
              const SizedBox(width: 8),
              PosIconSquareButton(
                icon: Icons.delete,
                onTap: onDelete,
                size: styles.iconButtonSize,
                radius: styles.iconButtonRadius,
                bg: styles.iconBtnBg,
                border: styles.iconBtnBorder,
              ),
            ],
          ),
          const SizedBox(height: 8),
          PosMoneyPill(
            text: _money(unitPrice),
            height: styles.pillHeight,
            radius: styles.pillRadius,
            style: styles.pillTextStyle,
            bg: styles.pillBg,
          ),
          const SizedBox(height: 8),
          PosQtyStepper(
            qty: qty,
            onMinus: onMinus,
            onPlus: onPlus,
            height: styles.stepperHeight,
            radius: styles.stepperRadius,
            bg: styles.stepperBg,
            border: styles.stepperBorder,
            qtyStyle: styles.qtyTextStyle,
          ),
        ],
      ),
    );
  }
}