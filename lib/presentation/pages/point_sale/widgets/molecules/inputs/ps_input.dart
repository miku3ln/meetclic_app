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
  final bool enabled;
  final bool selectAllOnFocus;
  final bool loading;
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
    this.selectAllOnFocus = true, // 👈 nuevo
    this.enabled = true, // 👈 nuevo
    this.loading = false,
  });

  @override
  State<PsInput> createState() => _PsInputState();
}
class _PsInputState extends State<PsInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller =
        TextEditingController(
          text: widget.value ?? "",
        );

    _focusNode =
        FocusNode();

    _focusNode.addListener(() {
      if (
      _focusNode.hasFocus &&
          widget.selectAllOnFocus
      ) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          _controller.selection =
              TextSelection(
                baseOffset: 0,
                extentOffset:
                _controller.text.length,
              );
        });
      }
    });
  }

  @override
  void didUpdateWidget(
      covariant PsInput oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (
    !_focusNode.hasFocus &&
        oldWidget.value != widget.value
    ) {
      _controller.text =
          widget.value ?? "";
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c =
    AppThemeTokens.of(context);

    final showError =
        widget.isTouched &&
            widget.error != null;

    final showSuccess =
        widget.isTouched &&
            widget.error == null &&
            widget.isValid;

    Color borderColor =
        c.border;

    Color labelColor =
        Colors.black;

    if (widget.enabled) {
      if (showError) {
        borderColor =
            c.error;

        labelColor =
            c.error;
      } else if (showSuccess) {
        borderColor =
            Colors.green;

        labelColor =
            Colors.green;
      }
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        /**
         * LABEL
         */
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style:
              AppTextStyles
                  .bodySecondary(context)
                  .copyWith(
                color: labelColor,
              ),
            ),

            if (widget.requiredField)
              Text(
                "*",
                style:
                TextStyle(
                  color: c.error,
                ),
              ),
          ],
        ),

        AppSpacing.spaceBetweenInputs,

        /**
         * VIEW INPUT
         */
        widget.loading
            ? _buildLoadingInput(
          c,
          borderColor,
        )
            : _buildNormalInput(
          c,
          borderColor,
          showError,
          showSuccess,
        ),
      ],
    );
  }

  /**
   * =====================================================
   * VIEW NORMAL
   * =====================================================
   */
  Widget _buildNormalInput(
      AppThemeTokens c,
      Color borderColor,
      bool showError,
      bool showSuccess,
      ) {
    return TextField(
      enabled:
      widget.enabled,

      focusNode:
      _focusNode,

      controller:
      _controller,

      onChanged:
      widget.enabled
          ? widget.onChanged
          : null,

      keyboardType:
      widget.keyboardType,

      decoration:
      InputDecoration(
        filled:
        true,

        fillColor:
        c.inputFill,

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(8),

          borderSide:
          BorderSide(
            color:
            borderColor,
          ),
        ),

        disabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(8),

          borderSide:
          BorderSide(
            color:
            c.border,
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(8),

          borderSide:
          BorderSide(
            color:
            borderColor,

            width:
            1.5,
          ),
        ),

        errorText:
        widget.enabled &&
            showError
            ? widget.error
            : null,

        suffixIcon:
        widget.enabled
            ? showError
            ? Icon(
          Icons.error_outline,
          color: c.error,
        )
            : showSuccess
            ? const Icon(
          Icons.check_circle,
          color: Colors.green,
        )
            : null
            : null,
      ),
    );
  }

  /**
   * =====================================================
   * VIEW LOADING
   * =====================================================
   */
  Widget _buildLoadingInput(
      AppThemeTokens c,
      Color borderColor,
      ) {
    return TextField(
      enabled:
      false,

      controller:
      _controller,

      keyboardType:
      widget.keyboardType,

      decoration:
      InputDecoration(
        filled:
        true,

        fillColor:
        c.inputFill,

        disabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(8),

          borderSide:
          BorderSide(
            color:
            borderColor,
          ),
        ),

        suffixIcon:
        Padding(
          padding:
          const EdgeInsets.all(12),

          child:
          SizedBox(
            width:
            18,

            height:
            18,

            child:
            CircularProgressIndicator(
              strokeWidth:
              2,

              color:
              c.primary,
            ),
          ),
        ),
      ),
    );
  }
}