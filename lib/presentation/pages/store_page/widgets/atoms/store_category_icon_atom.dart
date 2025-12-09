import 'package:flutter/material.dart';

import '../../theme/store_theme.dart';

class StoreCategoryIconAtom extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const StoreCategoryIconAtom({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? StoreTheme.categorySelectedBg
        : StoreTheme.categoryUnselectedBg;
    final iconColor = isSelected
        ? StoreTheme.categorySelectedText
        : StoreTheme.azulClic;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}
