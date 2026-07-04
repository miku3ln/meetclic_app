import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import '../drawers/pos_app_drawer.dart';

import '../templates/pos_split_template.dart';

import 'pos_main_controller.dart';
import 'tablet_landscape/pos_tablet_landscape_slots.dart';

class PosTabletLandscapeLayout extends StatefulWidget {


  const PosTabletLandscapeLayout({
    super.key

  });

  @override
  State<PosTabletLandscapeLayout> createState() =>
      _PosTabletLandscapeLayoutState();
}
class _PosTabletLandscapeLayoutState extends State<PosTabletLandscapeLayout> {
  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosMainController>();

    final slots = PosTabletLandscapeSlots.build(controller: controller);
    return PosSplitTemplate(slots: slots);

  }
}
