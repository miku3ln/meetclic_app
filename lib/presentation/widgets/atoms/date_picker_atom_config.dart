import 'package:flutter/material.dart';

class DatePickerAtomConfig {
  final Color? headerColor;
  final Color? headerTextColor;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? buttonTextColor;
  final Color? textColor;
  final Color? dayTextColor;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;

  const DatePickerAtomConfig({
    this.headerColor,
    this.headerTextColor,
    this.backgroundColor,
    this.iconColor,
    this.buttonTextColor,
    this.textColor,
    this.dayTextColor,
    this.labelStyle,
    this.textStyle,
  });

  /// Configuración por defecto accesible globalmente
  static const DatePickerAtomConfig defaultConfig = DatePickerAtomConfig();
}
