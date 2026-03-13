import 'package:flutter/material.dart';

import '../../../../../shared/theme/configuration/app_radius.dart';
import '../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../shared/theme/configuration/app_text_styles.dart';

class PosSettingsMenuStyles {
  PosSettingsMenuStyles._();

  static const double itemIconSize = 30;
  static const double itemTextSize = 18;
  static const double activeBorderWidth = 4;

  static const EdgeInsets itemPadding = EdgeInsets.only(
    left: AppSpacing.lg,
    top: AppSpacing.xxl,
    bottom: AppSpacing.xxl,
    right: AppSpacing.lg,
  );

  static const EdgeInsets footerPadding = EdgeInsets.all(AppSpacing.lg);

  static BoxDecoration containerDecoration(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    return BoxDecoration(
      color: colors.surface,
      border: Border(
        right: BorderSide(color: colors.border),
      ),
    );
  }

  static Color itemBackground(BuildContext context, {required bool selected}) {
    final colors = AppThemeTokens.of(context);
    return selected ? colors.primary.withOpacity(0.08) : Colors.transparent;
  }

  static Color itemForeground(BuildContext context, {required bool selected}) {
    final colors = AppThemeTokens.of(context);
    return selected ? colors.primary : colors.iconPrimary;
  }

  static Color itemTextColor(BuildContext context, {required bool selected}) {
    final colors = AppThemeTokens.of(context);
    return selected ? colors.primary : colors.textPrimary;
  }

  static Color itemBorderColor(BuildContext context, {required bool selected}) {
    final colors = AppThemeTokens.of(context);
    return selected ? colors.primary : Colors.transparent;
  }

  static TextStyle emailTextStyle(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    return AppTextStyles.bodySecondary(context).copyWith(
      fontSize: 16,
      color: colors.textSecondary,
    );
  }
}