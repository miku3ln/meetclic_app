// widgets/atoms/pos_money_pill.dart
import 'package:flutter/material.dart';

class PosMoneyPill extends StatelessWidget {
  final String text;
  final double height;
  final double radius;
  final TextStyle style;
  final Color bg;

  const PosMoneyPill({
    super.key,
    required this.text,
    required this.height,
    required this.radius,
    required this.style,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(text, style: style),
    );
  }
}