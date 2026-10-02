import 'package:flutter/material.dart';
import 'package:meetclic_app/shared/providers_session.dart';
import '../../../../shared/responsive/device_gesture_observer.dart';
import '../drawers/pos_app_drawer.dart';

import '../templates/pos_split_template.dart';

import 'pos_main_controller.dart';
import 'tablet_landscape/pos_tablet_landscape_slots.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  //INIT PROCESS-MANAGER-UI-02
  final DeviceSnapshot device;
  const PosTabletLandscapeLayout({super.key, required this.device});

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

class LandscapeLayout extends StatefulWidget {
  //INIT PROCESS-MANAGER-UI-02
  final DeviceSnapshot device;

  const LandscapeLayout({super.key, required this.device});

  @override
  State<LandscapeLayout> createState() => _LandscapeLayoutState();
}

class _LandscapeLayoutState extends State<LandscapeLayout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PosMainController>();
    final slots = PosLandScapeSlots.build(
      controller: controller,
      device: widget.device,
    );
    return LandSplitTemplate(slots: slots);
  }
}
