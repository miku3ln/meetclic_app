// point_sale/theme/pos_ticket_styles.dart
import 'package:flutter/material.dart';

class PosTicketStyles {
  // Layout
  final EdgeInsets listPadding;
  final double rowVerticalPadding;
  final double rowGap;
  final double leftThumbSize;
  final double leftThumbRadius;

  // Dividers
  final double dividerHeight;
  final Color dividerColor;

  // Text
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle ivaStyle;
  final TextStyle totalRightStyle;

  // Right actions
  final double rightColumnWidth;
  final double iconButtonSize;
  final double iconButtonRadius;

  // Pills / steppers
  final double pillHeight;
  final double pillRadius;
  final TextStyle pillTextStyle;

  final double stepperHeight;
  final double stepperRadius;
  final TextStyle qtyTextStyle;

  // Colors
  final Color mutedText;
  final Color pillBg;
  final Color stepperBg;
  final Color stepperBorder;
  final Color iconBtnBg;
  final Color iconBtnBorder;

  const PosTicketStyles({
    // Layout
    this.listPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.rowVerticalPadding = 10,
    this.rowGap = 12,
    this.leftThumbSize = 54,
    this.leftThumbRadius = 14,

    // Dividers
    this.dividerHeight = 1,
    this.dividerColor = const Color(0xFFE9EDF3),

    // Text
    this.titleStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    this.subtitleStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    this.ivaStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    this.totalRightStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),

    // Right actions
    this.rightColumnWidth = 118,
    this.iconButtonSize = 34,
    this.iconButtonRadius = 10,

    // Pills / steppers
    this.pillHeight = 26,
    this.pillRadius = 16,
    this.pillTextStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),

    this.stepperHeight = 30,
    this.stepperRadius = 16,
    this.qtyTextStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),

    // Colors
    this.mutedText = const Color(0xFF8A93A2),
    this.pillBg = const Color(0xFFF2F5FA),
    this.stepperBg = Colors.white,
    this.stepperBorder = const Color(0xFFE1E7F0),
    this.iconBtnBg = Colors.white,
    this.iconBtnBorder = const Color(0xFFE1E7F0),
  });

  PosTicketStyles copyWith({
    EdgeInsets? listPadding,
    double? rowVerticalPadding,
    double? rowGap,
    double? leftThumbSize,
    double? leftThumbRadius,
    double? dividerHeight,
    Color? dividerColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? ivaStyle,
    TextStyle? totalRightStyle,
    double? rightColumnWidth,
    double? iconButtonSize,
    double? iconButtonRadius,
    double? pillHeight,
    double? pillRadius,
    TextStyle? pillTextStyle,
    double? stepperHeight,
    double? stepperRadius,
    TextStyle? qtyTextStyle,
    Color? mutedText,
    Color? pillBg,
    Color? stepperBg,
    Color? stepperBorder,
    Color? iconBtnBg,
    Color? iconBtnBorder,
  }) {
    return PosTicketStyles(
      listPadding: listPadding ?? this.listPadding,
      rowVerticalPadding: rowVerticalPadding ?? this.rowVerticalPadding,
      rowGap: rowGap ?? this.rowGap,
      leftThumbSize: leftThumbSize ?? this.leftThumbSize,
      leftThumbRadius: leftThumbRadius ?? this.leftThumbRadius,
      dividerHeight: dividerHeight ?? this.dividerHeight,
      dividerColor: dividerColor ?? this.dividerColor,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      ivaStyle: ivaStyle ?? this.ivaStyle,
      totalRightStyle: totalRightStyle ?? this.totalRightStyle,
      rightColumnWidth: rightColumnWidth ?? this.rightColumnWidth,
      iconButtonSize: iconButtonSize ?? this.iconButtonSize,
      iconButtonRadius: iconButtonRadius ?? this.iconButtonRadius,
      pillHeight: pillHeight ?? this.pillHeight,
      pillRadius: pillRadius ?? this.pillRadius,
      pillTextStyle: pillTextStyle ?? this.pillTextStyle,
      stepperHeight: stepperHeight ?? this.stepperHeight,
      stepperRadius: stepperRadius ?? this.stepperRadius,
      qtyTextStyle: qtyTextStyle ?? this.qtyTextStyle,
      mutedText: mutedText ?? this.mutedText,
      pillBg: pillBg ?? this.pillBg,
      stepperBg: stepperBg ?? this.stepperBg,
      stepperBorder: stepperBorder ?? this.stepperBorder,
      iconBtnBg: iconBtnBg ?? this.iconBtnBg,
      iconBtnBorder: iconBtnBorder ?? this.iconBtnBorder,
    );
  }
}