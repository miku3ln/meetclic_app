import 'package:flutter/material.dart';
import '../slots/pos_layout_slots.dart';
import '../slots/pos_slot_config.dart';

class PosSplitTemplate extends StatelessWidget {//INIT PROCESS-MANAGER-UI-0
  final PosLayoutSlots slots;
  final PosSlotConfig config;
  const PosSplitTemplate({
    super.key,
    required this.slots,
    this.config = const PosSlotConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (slots.header != null) slots.header!,
        Expanded(
          child: Row(
            children: [
              Expanded(flex: config.leftFlex, child: slots.left ?? const SizedBox()),
              Expanded(flex: config.rightFlex, child: slots.right ?? const SizedBox()),
            ],
          ),
        ),

      ],
    );
  }
}


class PosLandTemplate extends StatelessWidget {//INIT PROCESS-MANAGER-UI-0
  final PosLayoutSlots slots;
  final PosSlotConfig config;
  const PosLandTemplate({
    super.key,
    required this.slots,
    this.config = const PosSlotConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (slots.header != null) slots.header!,
        Expanded(
          child: Row(
            children: [
              Expanded(flex: config.leftFlex, child: slots.left ?? const SizedBox()),
              Expanded(flex: config.rightFlex, child: slots.right ?? const SizedBox()),
            ],
          ),
        ),

      ],
    );
  }
}


class LandSplitTemplate extends StatelessWidget {//INIT PROCESS-MANAGER-UI-0
  final LayoutLandSlots slots;
  final PosSlotConfig config;
  const LandSplitTemplate({
    super.key,
    required this.slots,
    this.config = const PosSlotConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (slots.header != null) slots.header!,
        Expanded(
          child: Row(
            children: [
              Expanded(flex: config.leftFlex,child: slots.body ?? const SizedBox()),

            ],
          ),
        ),

      ],
    );
  }
}