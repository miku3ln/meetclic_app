import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';


class PsModalLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback?  onSave;

  const PsModalLayout({
    super.key,
    required this.title,
    required this.body,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.title(context)),
                IconButton(
                  icon: Icon(Icons.close, color: c.iconPrimary),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            AppSpacing.spaceBetweenSections,

            /// BODY
            Flexible(child: SingleChildScrollView(child: body)),

            AppSpacing.spaceBetweenSections,

            /// FOOTER
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                const SizedBox(width: AppSpacing.s),
                ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    onSave == null ? c.disabled : c.secondary,
                  ),
                  child: const Text("Guardar"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}