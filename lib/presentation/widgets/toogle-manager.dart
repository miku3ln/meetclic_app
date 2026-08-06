import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PsSegmentItem<T extends Object> {
  /// Valor del segmento
  final T value;

  /// Icono cuando está activo
  final IconData activeIcon;

  /// Icono cuando está inactivo
  final IconData inactiveIcon;

  /// Texto opcional
  final String? label;

  /// Color del thumb cuando este item está seleccionado
  final Color? thumbColor;

  /// Color del icono/texto cuando está activo
  final Color? activeColor;

  /// Color del icono/texto cuando está inactivo
  final Color? inactiveColor;

  const PsSegmentItem({
    required this.value,
    required this.activeIcon,
    required this.inactiveIcon,
    this.label,
    this.thumbColor,
    this.activeColor,
    this.inactiveColor,
  });
}

class PsSegmentToggle<T extends Object> extends StatelessWidget {
  /// Título opcional
  final String? title;

  final TextStyle? titleStyle;

  /// Espacio entre título y control
  final double titleSpacing;

  /// Valor seleccionado
  final T value;

  final List<PsSegmentItem<T>> items;

  final ValueChanged<T>? onChanged;

  final Color? borderColor;

  final Color? thumbColor;

  final Color activeForegroundColor;

  final Color inactiveForegroundColor;

  final double borderRadius;

  /// Padding del CupertinoSlidingSegmentedControl
  final EdgeInsetsGeometry padding;

  /// Padding interno de cada item
  final EdgeInsetsGeometry itemPadding;

  final double iconSize;

  final double spacing;

  /// Altura opcional
  final double? height;

  /// ancho mínimo del item
  final double? itemMinWidth;

  /// Alineación del título
  final CrossAxisAlignment titleAlignment;

  /// Estilo del texto del item
  final TextStyle? itemTextStyle;

  /// Peso del texto del item
  final FontWeight itemFontWeight;

  /// Tamaño del texto del item
  final double itemFontSize;

  /// Padding cuando no se envía itemPadding
  final EdgeInsetsGeometry defaultItemPadding;

  /// Color fondo del contenedor
  final Color? backgroundColor;

  /// Radio del icono/texto
  final BoxBorder? customBorder;

  /// Mostrar borde
  final bool showBorder;

  /// Espacio después del icono
  final double iconSpacing;

  /// Permitir interacción
  final bool enabled;

  const PsSegmentToggle({
    super.key,

    this.title,

    this.titleStyle,

    this.titleSpacing = 8,

    required this.value,

    required this.items,

    this.onChanged,

    this.borderColor,

    this.thumbColor,

    this.activeForegroundColor = Colors.white,
    this.inactiveForegroundColor = Colors.grey,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(4),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.iconSize = 20,
    this.spacing = 6,
    this.height,
    this.itemMinWidth,
    this.titleAlignment = CrossAxisAlignment.start,

    this.itemTextStyle,

    this.itemFontWeight = FontWeight.w600,

    this.itemFontSize = 14,

    this.defaultItemPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),

    this.backgroundColor,

    this.customBorder,

    this.showBorder = true,

    this.iconSpacing = 6,

    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    PsSegmentItem<T>? selectedItem;

    try {
      selectedItem = items.firstWhere((e) => e.value == value);
    } catch (_) {
      selectedItem = null;
    }

    final currentThumbColor = !enabled
        ? Colors.grey.shade300
        : thumbColor ?? selectedItem?.thumbColor ?? primary;

    return Column(
      crossAxisAlignment: titleAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style:
            titleStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
          ),
          SizedBox(height: titleSpacing),
        ],

        DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border:
            customBorder ??
                (showBorder
                    ? Border.all(
                  color: borderColor ?? Colors.grey.shade300,
                )
                    : null),
          ),

          child: enabled
              ? CupertinoSlidingSegmentedControl<T>(
            groupValue: value,
            padding: padding,
            thumbColor: currentThumbColor,
            children: {
              for (final item in items)
                item.value: _buildItem(item),
            },
            onValueChanged: (v) {
              if (v != null) {
                onChanged?.call(v);
              }
            },
          )
              : _buildDisabledSegment(),
        ),
      ],
    );
  }

  Widget _buildItem(PsSegmentItem<T> item) {
    final active = item.value == value;

    final color = !enabled
        ? Colors.grey.shade400
        : active
        ? (item.activeColor ?? activeForegroundColor)
        : (item.inactiveColor ?? inactiveForegroundColor);

    return Padding(
      padding: itemPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? item.activeIcon : item.inactiveIcon,
            size: iconSize,
            color: color,
          ),

          if (item.label != null) ...[
            SizedBox(width: spacing),

            Text(
              item.label!,
              style:
                  itemTextStyle ??
                  TextStyle(
                    color: color,
                    fontWeight: itemFontWeight,
                    fontSize: itemFontSize,
                  ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildDisabledSegment() {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {

          final active = item.value == value;

          return Container(
            constraints: BoxConstraints(
              minWidth: itemMinWidth ?? 0,
            ),
            padding: itemPadding,
            decoration: BoxDecoration(
              color: active
                  ? Colors.grey.shade300
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                borderRadius - 4,
              ),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Icon(
                  active
                      ? item.activeIcon
                      : item.inactiveIcon,
                  size: iconSize,
                  color: active
                      ? Colors.grey.shade700
                      : Colors.grey.shade400,
                ),

                if (item.label != null) ...[
                  SizedBox(width: spacing),

                  Text(
                    item.label!,
                    style: itemTextStyle ??
                        TextStyle(
                          color: active
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                          fontSize: itemFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
