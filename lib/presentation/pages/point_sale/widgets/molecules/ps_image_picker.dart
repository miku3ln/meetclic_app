import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

class PsImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onPick;
  final VoidCallback? onRemove;
  final String? error;

  final String label;
  final bool requiredField;
  final bool isTouched;
  final bool isValid;

  const PsImagePicker({
    super.key,
    required this.image,
    required this.onPick,
    this.onRemove,
    this.error,
    this.label = "Imagen",
    this.requiredField = false,
    this.isTouched = false,
    this.isValid = false,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final c = AppThemeTokens.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar imagen"),
        content: const Text("¿Deseas eliminar esta imagen?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Eliminar",
              style: TextStyle(color: c.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && onRemove != null) {
      onRemove!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    final showError = isTouched && error != null;
    final showSuccess = isTouched && error == null && isValid;

    Color borderColor = c.border;
    Color labelColor = c.textPrimary;

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

        /// 🔥 IMAGE PICKER
        Center(
          child: GestureDetector(
            onTap: onPick,
            child: Stack(
              children: [
                /// 🔲 CONTENEDOR
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: image == null
                      ? Icon(
                    Icons.camera_alt_outlined,
                    size: 40,
                    color: c.textSecondary,
                  )
                      : ClipOval(
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),

                /// ➕ BOTÓN AGREGAR
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),

                /// ❌ BOTÓN ELIMINAR (solo si hay imagen)
                if (image != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.error,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                /// ✅ / ⚠️ ESTADO VISUAL
                if (showError || showSuccess)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Icon(
                      showError
                          ? Icons.error_outline
                          : Icons.check_circle,
                      color: showError ? c.error : Colors.green,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),

        /// 🔴 ERROR
        if (showError) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: TextStyle(color: c.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}