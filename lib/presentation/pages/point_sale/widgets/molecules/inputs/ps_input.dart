import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

class PsInput extends StatelessWidget {
  final String label;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final String? error;
  final bool requiredField;

  /// 🔥 NUEVO
  final bool isTouched;
  final bool isValid;

  const PsInput({
    super.key,
    required this.label,
    this.onChanged,
    this.keyboardType,
    this.error,
    this.requiredField = false,
    this.isTouched = false,
    this.isValid = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    final showError = isTouched && error != null;
    final showSuccess = isTouched && error == null && isValid;

    Color borderColor = c.border;
    Color labelColor = Colors.black;

    if (showError) {
      borderColor = c.error;
      labelColor = c.error;
    } else if (showSuccess) {
      borderColor = Colors.green;
      labelColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 LABEL + REQUIRED
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySecondary(context).copyWith(
                color: labelColor,
              ),
            ),
            if (requiredField)
              Text(
                "*",
                style: TextStyle(
                  color: c.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),

        AppSpacing.spaceBetweenInputs,

        /// 🔹 INPUT
        TextField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.inputFill,

            /// 🔥 BORDE NORMAL
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),

            /// 🔥 FOCUS
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: borderColor,
                width: 1.5,
              ),
            ),

            /// 🔥 ERROR SOLO SI TOCADO
            errorText: showError ? error : null,

            /// 🔥 ICONOS DINÁMICOS
            suffixIcon: showError
                ? Icon(Icons.error_outline, color: c.error)
                : showSuccess
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}