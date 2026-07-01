
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../../../organisms/ps_toogle_group.dart';
class MeasureTypeConfiguration {
  const MeasureTypeConfiguration({
    required this.borderColor,
    required this.icon,
    required this.text,
  });

  final Color borderColor;
  final IconData icon;
  final String text;
}
class MeasureTypeUtils {
  const MeasureTypeUtils._();

  static MeasureTypeConfiguration getConfiguration({
    required String typeMeasureId,
  }) {
    final measureType = MeasureType.values.firstWhere(
          (e) => e.id == typeMeasureId,
      orElse: () => MeasureType.unit,
    );

    return MeasureTypeConfiguration(
      borderColor: measureType.color,
      icon: measureType.icon,
      text: measureType.value,
    );
  }
}