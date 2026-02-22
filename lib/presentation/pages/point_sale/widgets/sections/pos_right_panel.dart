import 'package:flutter/material.dart';

import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
class PosRightPanel extends StatelessWidget {
  final PosTabletLandscapeController controller;
  const PosRightPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        // leer: controller.ticketItems, controller.total, etc.
        return Container(
          child: Text('Items: ${controller.ticketItems.length}'),
        );
      },
    );
  }
}