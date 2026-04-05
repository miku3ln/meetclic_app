import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../domain/services/session_service.dart';
import '../../../../../../shared/controllers/app_controller.dart';

import '../../../models/sections_data.dart';
import '../../../shared/styles.dart';
import '../../../state/pos_items_controller.dart';
import '../../../state/pos_loyalty_controller.dart';

class PosLoyaltyMenu extends StatelessWidget {
  const PosLoyaltyMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PosLoyaltyController>();
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
                  icon: SectionsLoyalty.getIconItems(PosLoyaltySection.dashboard),
                  title: SectionsLoyalty.getTitleItems(PosLoyaltySection.dashboard),
                  selected: settings.section == PosLoyaltySection.dashboard,
                  onTap: () => settings.setSection(PosLoyaltySection.dashboard),
                ),
                menuItem(
                  context,
                  icon: SectionsLoyalty.getIconItems(PosLoyaltySection.cupon),
                  title:SectionsLoyalty.getTitleItems(PosLoyaltySection.cupon),
                  selected:
                  settings.section == PosLoyaltySection.cupon,
                  onTap: () =>
                      settings.setSection(PosLoyaltySection.cupon),
                ),
                menuItem(
                  context,
                  icon: SectionsLoyalty.getIconItems(PosLoyaltySection.gamification),
                  title:SectionsLoyalty.getTitleItems(PosLoyaltySection.gamification),
                  selected: settings.section == PosLoyaltySection.gamification,
                  onTap: () => settings.setSection(PosLoyaltySection.gamification),
                ),
                menuItem(
                  context,
                  icon: SectionsLoyalty.getIconItems(PosLoyaltySection.tracking),
                  title:SectionsLoyalty.getTitleItems(PosLoyaltySection.tracking),
                  selected: settings.section == PosLoyaltySection.tracking,
                  onTap: () => settings.setSection(PosLoyaltySection.tracking),
                ),
              ],
            ),
          ),
         
        ],
      ),
    );
  }


}