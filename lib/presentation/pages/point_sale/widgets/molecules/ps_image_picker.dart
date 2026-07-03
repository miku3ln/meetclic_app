import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
enum ImageSourceType {
  none,
  file,
  network,
  imageProvider,
  unsupported,
}

class ImageMapperResponse {
  final bool success;

  /// Tipo detectado
  final ImageSourceType type;

  /// Dato original (File, String, ImageProvider...)
  final Object? source;

  /// Para pintar en la UI
  final ImageProvider? provider;

  final String? message;
  final Object? error;

  const ImageMapperResponse({
    required this.success,
    required this.type,
    this.source,
    this.provider,
    this.message,
    this.error,
  });
}
class ImageMapper {
  static ImageMapperResponse map(Object? source) {
    try {
      if (source == null) {
        return const ImageMapperResponse(
          success: true,
          type: ImageSourceType.none,
        );
      }

      if (source is File) {
        return ImageMapperResponse(
          success: true,
          type: ImageSourceType.file,
          source: source,
          provider: FileImage(source),
        );
      }

      if (source is ImageProvider) {
        return ImageMapperResponse(
          success: true,
          type: ImageSourceType.imageProvider,
          source: source,
          provider: source,
        );
      }

      if (source is String) {
        final value = source.trim();

        if (value.isEmpty) {
          return const ImageMapperResponse(
            success: true,
            type: ImageSourceType.none,
          );
        }

        final isNetwork =
            value.startsWith('http://') ||
                value.startsWith('https://');

        return ImageMapperResponse(
          success: true,
          type: ImageSourceType.network,
          source: value,
          provider: isNetwork
              ? NetworkImage(value)
              : FileImage(File(value)),
        );
      }

      return ImageMapperResponse(
        success: false,
        type: ImageSourceType.unsupported,
        message: 'Tipo ${source.runtimeType} no soportado.',
      );
    } catch (e) {
      return ImageMapperResponse(
        success: false,
        type: ImageSourceType.unsupported,
        message: 'Error al procesar la imagen.',
        error: e,
      );
    }
  }
}
class PsImagePicker extends StatelessWidget {
  final Object? image;
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
  ImageProvider? _resolveImageProvider() {
    if (image == null) return null;

    if (image is ImageProvider) {
      return image as ImageProvider;
    }

    if (image is File) {
      return FileImage(image as File);
    }

    if (image is String) {
      final value = image as String;

      if (value.isEmpty) return null;

      if (value.startsWith('http://') ||
          value.startsWith('https://')) {
        return NetworkImage(value);
      }

      return FileImage(File(value));
    }

    return null;
  }
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
    final provider = _resolveImageProvider();
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
                  child: provider == null
                      ? Icon(
                    Icons.camera_alt_outlined,
                    size: 40,
                    color: c.textSecondary,
                  )
                      : ClipOval(
                    child: Image(
                      image: provider,
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