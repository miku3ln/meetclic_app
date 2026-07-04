import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../shared/models/api_response.dart';
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
  final bool isLoading;
  final bool allowActions;
  final StreamController<ManagementModalEvent>? eventController;

  const PsModalLayout({
    super.key,
    required this.title,
    required this.body,
    required this.onSave,
    required this.btnCancelTitle,
    required this.btnSaveTitle,
    this.useDialog = true,
    this.isLoading = false,
    this.allowActions = true,
    this.eventController,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);
    final content = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.title(context)),
            IconButton(
              icon: Icon(Icons.close, color: c.iconPrimary),
              onPressed: isLoading ? null :() {
                eventController?.add(ManagementModalEvent('closeBtnHeader'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        Expanded(child: body),
        AppSpacing.spaceBetweenSections,
        if (allowActions)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                        eventController?.add(ManagementModalEvent('cancelBtnFooter'));
                      },
                child: Text(btnCancelTitle),
              ),
              const SizedBox(width: AppSpacing.s),
              ElevatedButton(
                onPressed: (onSave == null || isLoading) ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onSave == null || isLoading
                      ? c.disabled
                      : c.secondary,
                ),
                child: Text(btnSaveTitle),
              ),
            ],
          ),
      ],
    );

    /// ============================
    /// WRAPPER CON LOADING OVERLAY
    /// ============================
    Widget wrappedContent = Stack(
      children: [
        content,

        if (isLoading) ...[
          const ModalBarrier(dismissible: false, color: Colors.black45),
          const Center(child: CircularProgressIndicator()),
        ],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.title(context)),
                    IconButton(
                      icon: Icon(Icons.close, color: c.iconPrimary),
                      onPressed: isLoading
                          ? null
                          : () {
                              eventController?.add(ManagementModalEvent('closeBtnHeader'));
                              Navigator.pop(context);
                            },
                    ),
                  ],
                ),

                AppSpacing.spaceBetweenSections,
                Flexible(
                  child: Stack(
                    children: [
                      SingleChildScrollView(child: body),

                      if (isLoading) ...[
                        const ModalBarrier(
                          dismissible: false,
                          color: Colors.black45,
                        ),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),
                ),

                AppSpacing.spaceBetweenSections,

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(btnCancelTitle),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    ElevatedButton(
                      onPressed: (onSave == null || isLoading) ? null : onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: onSave == null || isLoading
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
          child: Stack(
            children: [
              content,

              if (isLoading) ...[
                const ModalBarrier(dismissible: false, color: Colors.black45),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
