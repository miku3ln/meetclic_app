import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';


class PsFieldRow extends StatelessWidget {
  final List<Widget> children;

  const PsFieldRow({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if(isMobile){
      return Column(
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .expand(
            (widget) => [
          widget,
          const SizedBox(width: AppSpacing.m),
        ],
      ).toList()
        ..removeLast(),
    );
  }
}
class PsFieldItem extends StatelessWidget {
  final Widget child;
  final int flex;

  /// Porcentaje del ancho disponible
  /// Ejemplo: 0.25 = 25%
  final double? widthFactor;

  const PsFieldItem({
    super.key,
    required this.child,
    this.flex = 1,
    this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {

    if (widthFactor != null) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * widthFactor!,
        child: child,
      );
    }

    return Expanded(
      flex: flex,
      child: child,
    );
  }
}