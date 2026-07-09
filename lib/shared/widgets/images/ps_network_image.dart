import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/theme/configuration/app_theme_tokens.dart';

class PsNetworkImage extends StatelessWidget {
  final String? image;

  final double size;

  final double borderRadius;

  final BoxFit fit;

  final VoidCallback? onTap;

  const PsNetworkImage({
    super.key,
    this.image,
    this.size = 56,
    this.borderRadius = 28,
    this.fit = BoxFit.cover,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: size,
          height: size,
          child: image == null || image!.trim().isEmpty
              ? _buildPlaceholder(tokens)
              : Image.network(
            image!,
            fit: fit,
            loadingBuilder: (
                context,
                child,
                loadingProgress,
                ) {
              if (loadingProgress == null) {
                return AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 250),
                  child: child,
                );
              }

              return _buildLoading(
                tokens,
                loadingProgress,
              );
            },
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              debugPrint(
                "PsNetworkImage -> $error",
              );

              return _buildError(
                tokens,
                error,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(AppThemeTokens tokens) {
    return Container(
      color: tokens.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: size * .45,
        color: tokens.iconMuted,
      ),
    );
  }

  Widget _buildLoading(
      AppThemeTokens tokens,
      ImageChunkEvent progress,
      ) {
    double? value;

    if (progress.expectedTotalBytes != null) {
      value = progress.cumulativeBytesLoaded /
          progress.expectedTotalBytes!;
    }

    return Container(
      color: tokens.surfaceMuted,
      alignment: Alignment.center,
      child: SizedBox(
        width: size * .35,
        height: size * .35,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: 2.2,
          color: tokens.primary,
        ),
      ),
    );
  }

  Widget _buildError(
      AppThemeTokens tokens,
      Object error,
      ) {
    IconData icon = Icons.broken_image_outlined;

    if (error is SocketException) {
      icon = Icons.wifi_off_rounded;
    } else if (error is TimeoutException) {
      icon = Icons.timer_off_outlined;
    } else if (error is HandshakeException) {
      icon = Icons.security_outlined;
    } else if (error is HttpException) {
      icon = Icons.cloud_off_outlined;
    } else {
      final message = error.toString();

      if (message.contains("404")) {
        icon = Icons.hide_image_outlined;
      } else if (message.contains("403")) {
        icon = Icons.lock_outline;
      } else if (message.contains("500")) {
        icon = Icons.dns_outlined;
      }
    }

    return Tooltip(
      message: error.toString(),
      child: Container(
        color: tokens.errorBackground,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: tokens.error,
          size: size * .45,
        ),
      ),
    );
  }
}