import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
class PsInput extends StatefulWidget {
  final String label;
  final String? value;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final String? error;
  final bool requiredField;
  final bool isTouched;
  final bool isValid;

  const PsInput({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.keyboardType,
    this.error,
    this.requiredField = false,
    this.isTouched = false,
    this.isValid = false,
  });

  @override
  State<PsInput> createState() => _PsInputState();
}

class _PsInputState extends State<PsInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.value ?? "");
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PsInput oldWidget) {
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value ?? "";
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    final showError = widget.isTouched && widget.error != null;
    final showSuccess =
        widget.isTouched && widget.error == null && widget.isValid;

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
        /// LABEL
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.bodySecondary(context).copyWith(
                color: labelColor,
              ),
            ),
            if (widget.requiredField)
              Text("*", style: TextStyle(color: c.error)),
          ],
        ),

        AppSpacing.spaceBetweenInputs,

        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.inputFill,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            errorText: showError ? widget.error : null,
            suffixIcon: showError
                ? Icon(Icons.error_outline, color: c.error)
                : showSuccess
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
          ),
        ),
      ],
    );
  }
}