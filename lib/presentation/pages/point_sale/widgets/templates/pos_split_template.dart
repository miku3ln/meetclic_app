import 'package:flutter/material.dart';
import '../slots/pos_layout_slots.dart';
import '../slots/pos_slot_config.dart';

class PosSplitTemplate extends StatelessWidget {
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
        if (slots.footer != null)
          SafeArea(
            top: false,
            child: SizedBox(height: config.footerHeight, child: slots.footer),
          ),
      ],
    );
  }
}