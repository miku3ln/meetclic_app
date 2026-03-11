import 'package:flutter/material.dart';

import '../../../../../shared/controllers/app_controller.dart';
import '../dialogs/pos_open_shift_dialog.dart';
import '../drawers/pos_app_drawer.dart';
import '../templates/pos_split_template.dart';

import 'tablet_landscape/pos_tablet_landscape_controller.dart';
import 'tablet_landscape/pos_tablet_landscape_slots.dart';
import 'tablet_landscape/pos_tablet_landscape_fixtures.dart';
import 'package:provider/provider.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  const PosTabletLandscapeLayout({super.key});

  @override
  State<PosTabletLandscapeLayout> createState() =>
      _PosTabletLandscapeLayoutState();
}

class _PosTabletLandscapeLayoutState extends State<PosTabletLandscapeLayout> {
  late final PosTabletLandscapeController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // ✅
  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    controller = PosTabletLandscapeController(app: app)..addListener(_onChanged);
    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    // ✅ Conecta request del controller al modal (porque aquí sí hay context)
    controller.shift.onRequestOpenShift = _showOpenShiftModal;
    // ✅ Conecta evento del controller al Drawer
    controller.ui.onRequestOpenDrawer = () {
      _scaffoldKey.currentState?.openDrawer();
    };
    // ✅ Carga data inicial (fixtures)
    controller.init(
      initialProducts: PosTabletLandscapeFixtures.getProductsData(),
      initialProductCategories: PosTabletLandscapeFixtures.getCategoriesData(),
      initialMenuCategories: PosTabletLandscapeFixtures.getMenuCategoriesData(),
      // opcional:
       initialSelectedProductCategoryId: 'all',
       initialSelectedMenuCategoryId: 'all',
    );
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    controller.dispose();
    super.dispose();
  }

  // ✅ Modal vive aquí
  Future<void> _showOpenShiftModal() async {
    final opened = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PosOpenShiftDialog(controller: controller),
    );

    if (!mounted) return;
    if (opened != true) return;

  }

  @override
  Widget build(BuildContext context) {
    final slots = PosTabletLandscapeSlots.build(controller: controller);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const PosAppDrawer(), // ✅ tu drawer estilo Drive
      body: PosSplitTemplate(slots: slots),
    );
  }
}
