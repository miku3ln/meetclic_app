import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_radius.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';


class PsSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const PsSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title(context)),
          AppSpacing.spaceBetweenSections,
          child,
        ],
      ),
    );
  }
}