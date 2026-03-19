import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';


class PsFieldRow extends StatelessWidget {
  final List<Widget> children;

  const PsFieldRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map((e) => Expanded(child: e))
          .toList()
          .expand((widget) => [widget, const SizedBox(width: AppSpacing.m)])
          .toList()
        ..removeLast(),
    );
  }
}