import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../app/router/controllers/app_controller.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../../shared/utils/screen_utils.dart';
import '../../../state/pos_loyalty_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/loyalty/pos_loyalty_content.dart';
import '../../organisms/pos_settings_app_bar.dart';
import '../pos_main_controller.dart';
class PosLoyaltyLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final PosLoyaltySection section;
  const PosLoyaltyLayout({
    super.key,
    this.onMenuTap,required this.section
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosLoyaltyController(),
      child:  _PosLoyaltyView(section:section),
    );
  }
}

class _PosLoyaltyView extends StatelessWidget {
  final PosLoyaltySection section;
  final VoidCallback? onMenuTap;
  const _PosLoyaltyView({
    super.key,
    this.onMenuTap,
    required this.section,
});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final sectionTitle = "";
    final app = context.read<AppController>();

    final main =
    context.watch<PosMainController>();

    // =========================================================
    // DEVICE STATE
    // =========================================================

    final device = main.device;
    final appBarConfig = ScreenUtils.appBarConfigTitle(
      width: device.width,
      height: device.height,
      isLandscape: device.isLandscape,
      isTablet: device.isTablet,
    );
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      appBar: PosSettingsAppBar(
        titlePrimary:"Fidelización",
        titleSecondary:sectionTitle,
        showDivider: false,
        secondaryFlex: appBarConfig.primaryFlex,
        primaryFlex: appBarConfig.secondaryFlex,

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
      body:  Row(
        children: [

          Expanded(
            flex: 100,
            child: PosLoyaltyContent(section: section),
          ),
        ],
      ),
    );
  }
}