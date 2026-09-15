import 'package:flutter/material.dart';

import 'ManagerProcessMicro.dart';
import 'ManagerProcessMicroConfig.dart';
import 'ManagerProcessMicroResult.dart';

Future<ManagerProcessMicroResult<T>> showManagerProcessMicro<T>({
  required BuildContext context,
  required ManagerProcessMicroConfig config,
  required Widget form,
  required Future<ManagerProcessMicroResult<T>> Function() onSubmit,

  VoidCallback? onCancel,

  // Control dinámico del formulario
  Listenable? listenable,
  bool Function()? canSubmit,
}) async {
  final result =
  await showDialog<ManagerProcessMicroResult<T>>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return ManagerProcessMicro<T>(
        config: config,
        form: form,
        onSubmit: onSubmit,
        onCancel: onCancel,

        // Pasamos el estado al ManagerProcessMicro
        listenable: listenable,
        canSubmit: canSubmit,
      );
    },
  );

  return result ??
      ManagerProcessMicroResult<T>(
        success: false,
        data: null,
        message: 'El proceso finalizó sin resultado.',
        type: 'dismissed',
      );
}