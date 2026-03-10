import 'package:flutter/material.dart';
import '../../dialogs/pos_open_shift_dialog.dart';
import '../../templates/pos_split_template.dart';
import 'pos_tablet_landscape_controller.dart';
import 'pos_tablet_landscape_fixtures.dart';
import 'pos_tablet_landscape_slots.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  const PosTabletLandscapeLayout({super.key});

  @override
  State<PosTabletLandscapeLayout> createState() => _PosTabletLandscapeLayoutState();
}

class _PosTabletLandscapeLayoutState extends State<PosTabletLandscapeLayout> {
  late final PosTabletLandscapeController controller;

  @override
  void initState() {
    super.initState();

    controller = PosTabletLandscapeController()..addListener(_onControllerChanged);
    controller.shift.onRequestOpenShift = _showOpenShiftModal;

    controller.init(
      initialProducts: PosTabletLandscapeFixtures.getProductsData(),
      initialProductCategories: PosTabletLandscapeFixtures.getCategoriesData(),
      initialMenuCategories: PosTabletLandscapeFixtures.getMenuCategoriesData(),
      initialSelectedProductCategoryId:"all", //PosTabletLandscapeFixtures.all, // 'all'
      initialSelectedMenuCategoryId: "all"//PosTabletLandscapeFixtures.all,    // 'all'
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
    final initialCash = await showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PosOpenShiftDialog(),
    );
    if (initialCash == null) return;
    await controller.shift.openShift(initialCash);
  }

  @override
  Widget build(BuildContext context) {
    final slots = PosTabletLandscapeSlots.build(controller: controller);
    return PosSplitTemplate(slots: slots);
  }
}