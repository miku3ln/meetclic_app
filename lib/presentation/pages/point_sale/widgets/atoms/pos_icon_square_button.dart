// widgets/atoms/pos_icon_square_button.dart
import 'package:flutter/material.dart';

class PosIconSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double radius;
  final Color bg;
  final Color border;
  final Color? iconColor;

  const PosIconSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.size,
    required this.radius,
    required this.bg,
    required this.border,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border),
          ),
          child: Icon(icon, size: 18, color: iconColor ?? Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }
}