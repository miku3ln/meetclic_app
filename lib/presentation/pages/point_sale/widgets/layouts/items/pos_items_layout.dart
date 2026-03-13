import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/models/sections_data.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

import '../../../state/pos_items_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/items/pos_items_content.dart';
import '../../organisms/items/pos_items_menu.dart';
import '../../organisms/pos_settings_app_bar.dart';


class PosItemsLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const PosItemsLayout({
    super.key,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosItemsController(),
      child: const _PosItemsView(),
    );
  }
}

class _PosItemsView extends StatelessWidget {
  const _PosItemsView();

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final sectionTitle = context.watch<PosItemsController>().sectionTitle;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      appBar: PosSettingsAppBar(
        titlePrimary: Sections.getTitleItems(PosItemsSection.items),
        titleSecondary:sectionTitle,
        onMenuTap: () {
          scaffoldKey.currentState?.openDrawer();
        },
        style: PosSettingsAppBarStyle(
          topBackgroundColor: colors.primary,
          bottomBackgroundColor: colors.primary,
          primaryTitleColor: colors.textInverse,
          secondaryTitleColor: colors.textInverse,
          menuIconColor: colors.textInverse,
          primaryIndicatorColor: Colors.transparent,
          secondaryIndicatorColor: Colors.transparent,
          dividerColor: colors.divider,
        ),
      ),
      body: const Row(
        children: [
          Expanded(
            flex: 30,
            child: PosItemsMenu(),
          ),
          Expanded(
            flex: 70,
            child: PosItemsContent(),
          ),
        ],
      ),
    );
  }
}