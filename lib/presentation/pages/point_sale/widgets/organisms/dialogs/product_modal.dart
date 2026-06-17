import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

class PsModalLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onSave;
  final String btnCancelTitle;
  final String btnSaveTitle;
  final bool useDialog;

  const PsModalLayout({
    super.key,
    required this.title,
    required this.body,
    required this.onSave,
    required this.btnCancelTitle,
    required this.btnSaveTitle,
    this.useDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);
    final content = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.title(context),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: c.iconPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        Expanded(
            child: body,
        ),
        AppSpacing.spaceBetweenSections,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(btnCancelTitle),
            ),
            const SizedBox(width: AppSpacing.s),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                onSave == null ? c.disabled : c.secondary,
              ),
              child: Text(btnSaveTitle),
            ),
          ],
        ),
      ],
    );

    /// ============================
    /// MODAL
    /// ============================
    if (useDialog) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: SizedBox(
            width: 900,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title(context),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: c.iconPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                AppSpacing.spaceBetweenSections,

                Flexible(
                  child: SingleChildScrollView(
                    child: body,
                  ),
                ),

                AppSpacing.spaceBetweenSections,

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      child: Text(btnCancelTitle),
                    ),
                    const SizedBox(
                      width: AppSpacing.s,
                    ),
                    ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        onSave == null
                            ? c.disabled
                            : c.secondary,
                      ),
                      child: Text(btnSaveTitle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// ============================
    /// PÁGINA COMPLETA
    /// ============================
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: content,
        ),
      ),
    );
  }
}