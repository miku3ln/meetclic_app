import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/controllers/app_controller.dart';
import '../../dialogs/pos_open_shift_dialog.dart';
import '../../templates/pos_split_template.dart';
import 'pos_tablet_landscape_controller.dart';
import 'pos_tablet_landscape_fixtures.dart';
import 'pos_tablet_landscape_slots.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  const PosTabletLandscapeLayout({super.key});

  @override
  State<PosTabletLandscapeLayout> createState() =>
      _PosTabletLandscapeLayoutState();
}

class _PosTabletLandscapeLayoutState extends State<PosTabletLandscapeLayout> {
  late final PosTabletLandscapeController controller;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();

    controller = PosTabletLandscapeController(app: app)
      ..addListener(_onControllerChanged);

    controller.shift.onRequestOpenShift = _showOpenShiftModal;

    _initialize();
  }

  Future<void> _initialize() async {
    await controller.shift.init();

    controller.init(
      initialProducts: PosTabletLandscapeFixtures.getProductsData(),
      initialProductCategories: PosTabletLandscapeFixtures.getCategoriesData(),
      initialMenuCategories: PosTabletLandscapeFixtures.getMenuCategoriesData(),
      initialSelectedProductCategoryId: "all",
      initialSelectedMenuCategoryId: "all",
    );
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

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
    return PosSplitTemplate(slots: slots);
  }
}