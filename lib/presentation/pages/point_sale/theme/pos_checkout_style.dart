import 'dart:ui';

import 'package:flutter/material.dart';

class PosCheckoutStyle {
  final double radius;
  final double chipHeight;
  final double saveHeight;

  final Color border;

  final Color barBg;
  final Color chipBg;
  final Color chipFg;
  final Color chipSelectedBg;
  final Color chipSelectedFg;
  final Color chipSelectedBorder;

  final Color totalsBg;

  final TextStyle chipTextStyle;

  final TextStyle totalsLabelStyle;
  final TextStyle totalsValueStyle;
  final TextStyle totalLabelStyle;
  final TextStyle totalValueStyle;

  final ButtonStyle saveButtonStyle;

  PosCheckoutStyle({
    required this.radius,
    required this.chipHeight,
    required this.saveHeight,
    required this.border,
    required this.barBg,
    required this.chipBg,
    required this.chipFg,
    required this.chipSelectedBg,
    required this.chipSelectedFg,
    required this.chipSelectedBorder,
    required this.totalsBg,
    required this.chipTextStyle,
    required this.totalsLabelStyle,
    required this.totalsValueStyle,
    required this.totalLabelStyle,
    required this.totalValueStyle,
    required this.saveButtonStyle,
  });

  factory PosCheckoutStyle.of(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;

    final border = scheme.outlineVariant.withOpacity(0.75);
    final saveBg = const Color(0xFF2EA44F);

    return PosCheckoutStyle(
      radius: 14,
      chipHeight: 42,
      saveHeight: 48,
      border: border,
      barBg: t.cardColor,
      chipBg: t.cardColor,
      chipFg: t.textTheme.bodyMedium?.color ?? Colors.black87,
      chipSelectedBg: saveBg.withOpacity(0.12),
      chipSelectedFg: saveBg,
      chipSelectedBorder: saveBg.withOpacity(0.55),
      totalsBg: const Color(0xFFF4F6FF),
      chipTextStyle: t.textTheme.bodySmall?.copyWith(fontSize: 12) ??
          const TextStyle(fontSize: 12),
      totalsLabelStyle: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
          const TextStyle(fontWeight: FontWeight.w600),
      totalsValueStyle: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700) ??
          const TextStyle(fontWeight: FontWeight.w700),
      totalLabelStyle: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800) ??
          const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      totalValueStyle: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900) ??
          const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      saveButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: saveBg,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800) ??
            const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}