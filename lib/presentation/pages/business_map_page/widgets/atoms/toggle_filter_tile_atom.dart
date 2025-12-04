import 'package:flutter/material.dart';

/// 🎨 Configuración opcional de colores para el toggle.
/// Si no la envías, se toma todo del Theme.
class ToggleFilterTileColors {
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? activeColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? tileColor;

  const ToggleFilterTileColors({
    this.titleColor,
    this.subtitleColor,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.tileColor,
  });

  factory ToggleFilterTileColors.fromTheme(ThemeData theme) {
    final cs = theme.colorScheme;
    return ToggleFilterTileColors(
      titleColor: cs.onSurface,
      subtitleColor: cs.onSurface.withOpacity(0.7),
      activeColor: cs.primary,
      activeTrackColor: cs.secondary,
      inactiveTrackColor: cs.primary.withOpacity(0.4),
      tileColor: Colors.transparent,
    );
  }
}

class ToggleFilterTileAtom extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Opcional: permite personalizar colores. Si es null, se usan los del theme.
  final ToggleFilterTileColors? colors;

  const ToggleFilterTileAtom({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColors = colors ?? ToggleFilterTileColors.fromTheme(theme);

    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      tileColor: resolvedColors.tileColor,
      activeColor: resolvedColors.activeColor,
      activeTrackColor: resolvedColors.activeTrackColor,
      inactiveTrackColor: resolvedColors.inactiveTrackColor,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: resolvedColors.titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: resolvedColors.subtitleColor,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
