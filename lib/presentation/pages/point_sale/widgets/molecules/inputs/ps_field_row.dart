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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .expand(
            (widget) => [
          widget,
          const SizedBox(width: AppSpacing.m),
        ],
      )
          .toList()
        ..removeLast(),
    );
  }
}


class PsFieldItem extends StatelessWidget {
  final Widget child;
  final int flex;

  const PsFieldItem({
    super.key,
    required this.child,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }
}