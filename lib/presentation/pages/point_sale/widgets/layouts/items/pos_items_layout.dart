import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/models/sections_data.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../../shared/utils/screen_utils.dart';
import '../../../state/pos_items_controller.dart';
import '../../drawers/pos_app_drawer.dart';
import '../../organisms/items/pos_items_content.dart';
import '../../organisms/pos_settings_app_bar.dart';
import '../pos_main_controller.dart';

class PosItemsLayout extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final PosItemsSection section;
  const PosItemsLayout({super.key, this.onMenuTap,required this.section});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PosItemsController(),
      child:  _PosItemsView(section:section),
    );
  }
}
class _PosItemsView extends StatefulWidget {
  final PosItemsSection section;
  final VoidCallback? onMenuTap;

  const _PosItemsView({
    super.key,
    this.onMenuTap,
    required this.section,
  });

  @override
  State<_PosItemsView> createState() => _PosItemsViewState();
}

class _PosItemsViewState extends State<_PosItemsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);

    final main =
    context.watch<PosMainController>();

    // =========================================================
    // DEVICE STATE
    // =========================================================

    final device = main.device;

    final width = device.width;
    final height = device.height;

    final isLandscape =
        device.isLandscape;

    final isPortrait =
        device.isPortrait;

    final isTablet =
        device.isTablet;

    final layoutType =
        device.layoutType;

    var sectionTitle =
        'Dispositivo: ${isTablet ? 'Tablet' : 'Móvil'}'
        ' | Orientación: ${isLandscape ? 'Horizontal' : 'Vertical'}'
        ' | Ancho: ${width.toStringAsFixed(0)}'
        ' | Alto: ${height.toStringAsFixed(0)}'
        ' | Layout: ${layoutType.name}';
    sectionTitle="";
    final appBarConfig = ScreenUtils.appBarConfigTitle(
      width: device.width,
      height: device.height,
      isLandscape: device.isLandscape,
      isTablet: device.isTablet,
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      drawer: const PosAppDrawer(),
      appBar: PosSettingsAppBar(
        titlePrimary: Sections.getTitleItems(
          PosItemsSection.items,
        ),
        titleSecondary: sectionTitle,
        showDivider: false,
        secondaryFlex: appBarConfig.secondaryFlex,
        primaryFlex: appBarConfig.primaryFlex,

        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
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
      body: Row(
        children: [
          Expanded(
            flex: 100,
            child: PosItemsContent(
              section: widget.section,
            ),
          ),
        ],
      ),
    );
  }
}