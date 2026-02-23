// widgets/atoms/pos_qty_stepper.dart
import 'package:flutter/material.dart';

class PosQtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  final double height;
  final double radius;
  final Color bg;
  final Color border;
  final TextStyle qtyStyle;

  const PosQtyStepper({
    super.key,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
    required this.height,
    required this.radius,
    required this.bg,
    required this.border,
    required this.qtyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniIcon(icon: Icons.remove, onTap: onMinus),
          const SizedBox(width: 8),
          Text('$qty', style: qtyStyle),
          const SizedBox(width: 8),
          _MiniIcon(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16),
      ),
    );
  }
}