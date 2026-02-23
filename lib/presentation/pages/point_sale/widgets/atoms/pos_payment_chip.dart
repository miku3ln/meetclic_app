import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/pos_checkout_style.dart';

class PosPaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const PosPaymentChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = PosCheckoutStyle.of(context);

    return Material(
      color: selected ? s.chipSelectedBg : s.chipBg,
      borderRadius: BorderRadius.circular(s.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(s.radius),
        onTap: onTap,
        child: Container(
          height: s.chipHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          constraints: const BoxConstraints(minWidth: 120), // 👈 base
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(s.radius),
            border: Border.all(
              color: selected ? s.chipSelectedBorder : s.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 👈 ancho “natural”
            children: [
              Icon(icon, size: 18, color: selected ? s.chipSelectedFg : s.chipFg),
              const SizedBox(width: 8),
              Text(
                label,
                style: s.chipTextStyle.copyWith(
                  color: selected ? s.chipSelectedFg : s.chipFg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}