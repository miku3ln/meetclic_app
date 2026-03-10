
import 'dart:ui';

import 'package:flutter/material.dart';


class PosCheckoutToggleColors {
  final Color payActiveBg;
  final Color payActiveFg;
  final Color saveActiveBg;
  final Color saveActiveFg;

  final Color inactiveBg;
  final Color inactiveFg;
  final Color border;

  const PosCheckoutToggleColors({
    required this.payActiveBg,
    required this.payActiveFg,
    required this.saveActiveBg,
    required this.saveActiveFg,
    required this.inactiveBg,
    required this.inactiveFg,
    required this.border,
  });

  // Defaults (puedes mover luego a theme)
  factory PosCheckoutToggleColors.defaults() {
    return PosCheckoutToggleColors(
      payActiveBg: Colors.green,
      payActiveFg: Colors.white,
      saveActiveBg: Colors.amber,
      saveActiveFg: Colors.black,
      inactiveBg: Colors.white,
      inactiveFg: Colors.black87,
      border: Colors.black12,
    );
  }
}
class PosCheckoutToggleIcons {
  final IconData save;
  final IconData pay;

  const PosCheckoutToggleIcons({
    required this.save,
    required this.pay,
  });

  factory PosCheckoutToggleIcons.defaults() {
    return const PosCheckoutToggleIcons(
      save: Icons.save_rounded,
      pay: Icons.payment_rounded, // o Icons.point_of_sale_rounded
    );
  }
}