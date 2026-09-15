import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/configuration/app_theme_tokens.dart';
import 'ManagerProcessMicroConfig.dart';
import 'ManagerProcessMicroResult.dart';

class ManagerProcessMicro<T> extends StatelessWidget {
  final ManagerProcessMicroConfig config;

  final Widget form;
  final Listenable? listenable;
  final Future<ManagerProcessMicroResult<T>> Function() onSubmit;
  final bool Function()? canSubmit;
  final VoidCallback? onCancel;

  const ManagerProcessMicro({
    super.key,
    required this.config,
    required this.form,
    required this.onSubmit,
    this.onCancel,
    this.listenable,
    this.canSubmit,

  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final size = MediaQuery.of(context).size;

    final drawerWidth = size.width > 500
        ? config.maxWidth
        : size.width * .92;

    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: drawerWidth,
            height: size.height,
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                bottomLeft: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadow,
                  blurRadius: 30,
                  offset: const Offset(-8, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                bottomLeft: Radius.circular(28),
              ),
              child: Column(
                children: [
                  _buildHeader(context),

                  Divider(
                    height: 1,
                    color: tokens.border,
                  ),

                  Expanded(
                    child: Container(
                      color: tokens.background,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: form,
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: tokens.border,
                  ),

                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        20,
        20,
      ),
      child: Row(
        children: [
          Icon(
            config.icon,
            color: tokens.primary,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),

                if (config.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    config.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.of(context).pop(
                ManagerProcessMicroResult<T>(
                  success: true,
                  data: null,
                  message: 'Proceso cerrado',
                  type: 'close',
                ),
              );
            },
            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFooter(BuildContext context) {
    if (listenable == null) {
      return _buildFooterContent(context);
    }

    return ListenableBuilder(
      listenable: listenable!,
      builder: (context, _) {
        return _buildFooterContent(context);
      },
    );
  }

  Widget _buildFooterContent(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    final submitEnabled =
        canSubmit?.call() ?? true;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  onCancel?.call();

                  Navigator.of(context).pop(
                    ManagerProcessMicroResult<T>(
                      success: true,
                      data: null,
                      message: 'Proceso cancelado',
                      type: 'cancel',
                    ),
                  );
                },
                child: Text(
                  config.cancelText,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                  tokens.buttonPrimaryBackground,
                  foregroundColor:
                  tokens.buttonPrimaryForeground,
                ),

                // 🔥 null = botón deshabilitado
                onPressed: !submitEnabled
                    ? null
                    : () async {
                  final result =
                  await onSubmit();

                  if (!context.mounted) {
                    return;
                  }

                  if (result.success) {
                    Navigator.of(context)
                        .pop(result);
                  }
                },

                child: Text(
                  config.submitText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}