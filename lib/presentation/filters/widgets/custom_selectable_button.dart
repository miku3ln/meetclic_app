import 'package:flutter/material.dart';

class CustomSelectableButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const CustomSelectableButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.fontSize,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isSelected
        ? (selectedColor ?? Theme.of(context).colorScheme.primary)
        : (unselectedColor ?? Colors.grey.shade200);

    final Color textColor = isSelected
        ? (selectedTextColor ?? Colors.white)
        : (unselectedTextColor ?? Colors.black87);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? backgroundColor : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 13,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
