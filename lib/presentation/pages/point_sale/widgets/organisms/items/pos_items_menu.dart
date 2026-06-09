import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../domain/services/session_service.dart';
import '../../../../../../shared/controllers/app_controller.dart';

import '../../../models/sections_data.dart';
import '../../../shared/styles.dart';
import '../../../state/pos_items_controller.dart';

class PosItemsMenu extends StatelessWidget {//MENU MANAGEMENT PRODUCTS
  const PosItemsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PosItemsController>();
    final app = context.read<AppController>();
    final session = context.watch<SessionService>();
    return Container(
      decoration: PosSettingsMenuStyles.containerDecoration(context),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                menuItem(
                  context,
                  icon: Sections.getIconItems(PosItemsSection.categories),
                  title:Sections.getTitleItems(PosItemsSection.categories),
                  selected:
                  settings.section == PosItemsSection.categories,
                  onTap: () =>
                      settings.setSection(PosItemsSection.categories),
                ),
               /* menuItem(
                  context,
                  icon: Sections.getIconItems(PosItemsSection.modifiers),
                  title: Sections.getTitleItems(PosItemsSection.modifiers),
                  selected: settings.section == PosItemsSection.modifiers,
                  onTap: () => settings.setSection(PosItemsSection.modifiers),
                ),*/

                menuItem(
                  context,
                  icon: Sections.getIconItems(PosItemsSection.items),
                  title: Sections.getTitleItems(PosItemsSection.items),
                  selected: settings.section == PosItemsSection.items,
                  onTap: () => settings.setSection(PosItemsSection.items),
                ),
                menuItem(
                  context,
                  icon: Sections.getIconItems(PosItemsSection.discounts),

                  title:Sections.getTitleItems(PosItemsSection.discounts),
                  selected: settings.section == PosItemsSection.discounts,
                  onTap: () => settings.setSection(PosItemsSection.discounts),
                ),
              ],
            ),
          ),
         
        ],
      ),
    );
  }


}