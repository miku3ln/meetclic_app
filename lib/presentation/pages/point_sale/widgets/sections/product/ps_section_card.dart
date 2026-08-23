import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_radius.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

class PsSectionSplit extends StatelessWidget {
  final Widget left;
  final Widget right;

  final int leftFlex;
  final int rightFlex;

  const PsSectionSplit({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: leftFlex,
          child: left,
        ),

        const SizedBox(
          width: AppSpacing.m,
        ),

        Expanded(
          flex: rightFlex,
          child: right,
        ),
      ],
    );
  }
}
Widget infoRow(
    IconData icon,
    String? text, {
      String? label,
      VoidCallback? onTap,
      Widget? trailing,
      String? tooltip,
    }) {
  if (text == null || text.trim().isEmpty) {
    return const SizedBox.shrink();
  }

  final hasLabel = label != null && label.trim().isNotEmpty;
  final isInteractive = onTap != null;

  final content = Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 10,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: isInteractive ? null : Colors.grey,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: hasLabel
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(
                  fontWeight:
                  isInteractive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          )
              : Text(
            text,
            style: TextStyle(
              fontWeight:
              isInteractive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),

        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ] else if (isInteractive) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: Colors.grey,
          ),
        ],
      ],
    ),
  );

  if (!isInteractive) {
    return content;
  }

  final tappable = Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    ),
  );

  if (tooltip != null && tooltip.trim().isNotEmpty) {
    return Tooltip(
      message: tooltip,
      child: tappable,
    );
  }

  return tappable;
}
class PsSectionCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const PsSectionCard({
    super.key,
    this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    final hasTitle = title != null && title!.trim().isNotEmpty;

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
          if (hasTitle) ...[
            Text(
              title!,
              style: AppTextStyles.title(context),
            ),
            AppSpacing.spaceBetweenSections,
          ],
          child,
        ],
      ),
    );
  }
}