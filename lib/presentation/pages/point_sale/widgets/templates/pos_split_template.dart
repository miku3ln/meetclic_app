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
        // HEADER (AppBar) como widget normal
        if (slots.header != null) slots.header!,

        // FILA 1
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: config.leftFlex,
                child: _Scrollable(child: slots.left),
              ),
              Expanded(
                flex: config.rightFlex,
                child: _Scrollable(child: slots.right),
              ),
            ],
          ),
        ),

        // FILA 2 (FOOTER FIJO)
        if (slots.footer != null)
          SafeArea(
            top: false,
            child: SizedBox(
              height: config.footerHeight,
              child: slots.footer,
            ),
          ),
      ],
    );
  }
}

class _Scrollable extends StatefulWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;

  const _Scrollable({
    super.key,
    this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<_Scrollable> createState() => _ScrollableState();
}

class _ScrollableState extends State<_Scrollable> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: false,
      child: SingleChildScrollView(
        controller: _controller,
        primary: false, // 🔥 clave: no usar PrimaryScrollController
        padding: widget.padding,
        child: widget.child ?? const SizedBox(),
      ),
    );
  }
}