import 'package:flutter/material.dart';
import '../drawers/pos_app_drawer.dart';

import '../templates/pos_split_template.dart';

import 'tablet_landscape/pos_tablet_landscape_controller.dart';
import 'tablet_landscape/pos_tablet_landscape_slots.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  final PosTabletLandscapeController controller;
  final scaffoldKey;
  const PosTabletLandscapeLayout({
    super.key,
    required this.controller,
    required this.scaffoldKey,
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
    return Scaffold(
      key: widget.scaffoldKey,
      drawer: const PosAppDrawer(), // ✅ tu drawer estilo Drive
      body: PosSplitTemplate(slots: slots),
    );
  }
}
