import 'package:flutter/material.dart';
import '../drawers/pos_app_drawer.dart';

import '../templates/pos_split_template.dart';

import 'pos_main_controller.dart';
import 'tablet_landscape/pos_tablet_landscape_slots.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  final PosMainController controller;

  const PosTabletLandscapeLayout({
    super.key,
    required this.controller,

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
    final slots = PosTabletLandscapeSlots.build(controller: widget.controller);
    return PosSplitTemplate(slots: slots);

  }
}
