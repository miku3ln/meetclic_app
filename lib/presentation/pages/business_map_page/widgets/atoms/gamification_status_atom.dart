import 'package:flutter/material.dart';

import '../../models/meet_clic_colors.dart';

class GamificationStatusAtom extends StatelessWidget {
  final BusinessGamificationTypeConfig config;

  const GamificationStatusAtom({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: config.badgeBackgroundColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(config.icon, size: 18, color: config.primaryColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _buildGamificationTitleFromConfig(config),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: config.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  String _buildGamificationTitleFromConfig(
    BusinessGamificationTypeConfig config,
  ) {
    switch (config.type) {
      case BusinessGamificationType.none:
        return '${config.andeanSymbolName} – Sin gamificación';
      case BusinessGamificationType.basic:
        return '${config.andeanSymbolName} – Gamificación activa';
      case BusinessGamificationType.redeemLocal:
        return '${config.andeanSymbolName} – Canje en esta empresa';
      case BusinessGamificationType.redeemAllies:
        return '${config.andeanSymbolName} – Canje en red de aliados';
    }
  }
}
