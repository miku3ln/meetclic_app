import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/configuration/app_text_styles.dart';
import '../shared/styles.dart';
import '../state/pos_items_controller.dart';

class Sections {
  static String getTitleItems(PosItemsSection type) {
    switch (type) {
      case PosItemsSection.items:
        return 'Artículos';
      case PosItemsSection.categories:
        return 'Categorías';

      case PosItemsSection.modifiers:
        return 'Modificadores';
      case PosItemsSection.discounts:
        return 'Descuentos';
      default:
        return '';
    }
  }

  static IconData getIconItems(PosItemsSection type) {
    switch (type) {
      case PosItemsSection.items:
        return  Icons.format_list_bulleted;
      case PosItemsSection.categories:
        return Icons.copy_rounded;

      case PosItemsSection.modifiers:
        return Icons.note_alt_outlined;
      case PosItemsSection.discounts:
        return Icons.local_offer_outlined;
      default:
        return Icons.menu;
    }
  }
}

Widget menuItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required bool selected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: PosSettingsMenuStyles.itemBackground(
          context,
          selected: selected,
        ),
        border: Border(
          left: BorderSide(
            color: PosSettingsMenuStyles.itemBorderColor(
              context,
              selected: selected,
            ),
            width: PosSettingsMenuStyles.activeBorderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: PosSettingsMenuStyles.itemPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: PosSettingsMenuStyles.itemForeground(
                context,
                selected: selected,
              ),
              size: PosSettingsMenuStyles.itemIconSize,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.menuItem(context, selected: selected)
                    .copyWith(
                      fontSize: PosSettingsMenuStyles.itemTextSize,
                      color: PosSettingsMenuStyles.itemTextColor(
                        context,
                        selected: selected,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
