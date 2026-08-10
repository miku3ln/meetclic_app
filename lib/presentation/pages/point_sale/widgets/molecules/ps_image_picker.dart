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

    const double imageSize = 130;
    const double actionSize = 42;
    const double componentWidth = 170;

    return Center(
      child: SizedBox(
        width: componentWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// LABEL
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySecondary(context).copyWith(
                    color: labelColor,
                  ),
                  children: [
                    TextSpan(text: label),
                    if (requiredField)
                      TextSpan(
                        text: " *",
                        style: TextStyle(color: c.error),
                      ),
                  ],
                ),
              ),
            ),

            AppSpacing.spaceBetweenInputs,

            GestureDetector(
              onTap: onPick,
              child: Column(
                children: [

                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [

                      /// FOTO
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: imageSize,
                        height: imageSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.surface,
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                        child: provider == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Icon(
                              Icons.camera_alt_outlined,
                              size: 42,
                              color: c.textSecondary,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Agregar",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        )
                            : ClipOval(
                          child: Image(
                            image: provider,
                            fit: BoxFit.cover,
                            width: imageSize,
                            height: imageSize,
                          ),
                        ),
                      ),

                      /// ELIMINAR
                      if (provider != null)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Material(
                            elevation: 4,
                            color: c.error,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _confirmDelete(context),
                              child: const SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),

                      /// BOTON EDITAR
                      Positioned(
                        bottom: -8,
                        child: Material(
                          elevation: 6,
                          color: c.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onPick,
                            child: SizedBox(
                              width: actionSize,
                              height: actionSize,
                              child: Icon(
                                provider == null
                                    ? Icons.add
                                    : Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            ),

            if (showError) ...[
              const SizedBox(height: 10),

              Icon(
                Icons.error_outline,
                color: c.error,
                size: 18,
              ),

              const SizedBox(height: 4),

              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}