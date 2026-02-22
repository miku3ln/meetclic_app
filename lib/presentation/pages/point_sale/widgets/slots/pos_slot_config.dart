import 'package:flutter/foundation.dart';

@immutable
class PosSlotConfig {
  final int leftFlex;
  final int rightFlex;
  final double footerHeight;

  const PosSlotConfig({
    this.leftFlex = 70,
    this.rightFlex = 30,
    this.footerHeight = 96, // 🔥 sube para que se note
  });
}