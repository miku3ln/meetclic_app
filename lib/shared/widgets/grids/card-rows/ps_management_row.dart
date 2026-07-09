import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/configuration/app_theme_tokens.dart';
import '../../images/ps_network_image.dart';

enum PsEntityState {
  active,
  inactive,
  draft,
}

extension PsEntityStateExtension on PsEntityState {
  String get label {
    switch (this) {
      case PsEntityState.active:
        return "Activo";
      case PsEntityState.inactive:
        return "Inactivo";
      case PsEntityState.draft:
        return "Borrador";
    }
  }
}

class PsInfoChip {
  final IconData? icon;
  final String label;

  const PsInfoChip({
    this.icon,
    required this.label,
  });
}
class PsManagementRow extends StatelessWidget {
  final String? image;

  final String title;
  final String subtitle;
  final String description;

  final PsEntityState state;

  final List<PsInfoChip> chips;

  final VoidCallback? onTap;

  final Widget? trailing;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onTrailingTap;

  final double imageSize;
  final double borderRadius;

  final double titleFontSize;
  final double subtitleFontSize;
  final double descriptionFontSize;
  const PsManagementRow({
    super.key,
    this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.state,

    this.chips = const [],

    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onImageTap,
    this.onTrailingTap,

    this.trailing,

    this.imageSize = 56,
    this.borderRadius = 28,
    this.titleFontSize = 17,
    this.subtitleFontSize = 14,
    this.descriptionFontSize = 13,
  });

  Color _stateColor(AppThemeTokens tokens) {
    switch (state) {
      case PsEntityState.active:
        return tokens.success;

      case PsEntityState.inactive:
        return tokens.error;

      case PsEntityState.draft:
        return tokens.warning;
    }
  }

  Color _stateBackground(AppThemeTokens tokens) {
    switch (state) {
      case PsEntityState.active:
        return tokens.successBackground;

      case PsEntityState.inactive:
        return tokens.errorBackground;

      case PsEntityState.draft:
        return tokens.warningBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    final stateColor = _stateColor(tokens);
    final stateBackground = _stateBackground(tokens);

    return Material(
      color: tokens.cardBackground,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Imagen
              PsNetworkImage(
                image: image,
                size: 56,
                borderRadius: 28,
                onTap: onImageTap,
              ),
              const SizedBox(width: 16),

              /// Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Título + Estado
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: stateBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            state.label,
                            style: TextStyle(
                              color: stateColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: tokens.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],

                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: chips.map((chip) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.badge,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                if (chip.icon != null)
                                  Icon(
                                    chip.icon,
                                    size: 15,
                                    color: tokens.badgeText,
                                  ),

                                if (chip.icon != null)
                                  const SizedBox(width: 6),

                                Text(
                                  chip.label,
                                  style: TextStyle(
                                    color: tokens.badgeText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              if (trailing != null) ...[
                const SizedBox(width: 12),

                InkWell(
                  onTap: onTrailingTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: trailing!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
