import 'package:flutter/material.dart';
import '../models/pos_action_item.dart';

class PosActionBar extends StatelessWidget {
  // Izquierda (dinámico)
  final List<PosActionItem> leftActions;

  // Derecha (fijo)
  final VoidCallback onSave;
  final VoidCallback onPay;

  // Config
  final double height;
  final double rightWidth; // ancho fijo del bloque "Guardar/Cobrar"
  final EdgeInsets padding;

  const PosActionBar({
    super.key,
    required this.leftActions,
    required this.onSave,
    required this.onPay,
    this.height = 84,
    this.rightWidth = 360, // en tablet landscape se ve bien
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              // LEFT: dinámico (scroll horizontal)
              Expanded(
                child: _LeftActionsCarousel(actions: leftActions),
              ),

              const SizedBox(width: 12),

              // DIVIDER
              const VerticalDivider(width: 1),

              const SizedBox(width: 12),

              // RIGHT: fijo (2 columnas)
              SizedBox(
                width: rightWidth,
                child: _RightFixedActions(
                  onSave: onSave,
                  onPay: onPay,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeftActionsCarousel extends StatelessWidget {
  final List<PosActionItem> actions;

  const _LeftActionsCarousel({required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(''),
      );
    }

    return Scrollbar(
      thumbVisibility: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions.map((a) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _ChipButton(
                label: a.name,
                enabled: a.enabled,
                onTap: a.enabled ? a.onTap : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _ChipButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _RightFixedActions extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onPay;

  const _RightFixedActions({
    required this.onSave,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text('GUARDAR'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onPay,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text('COBRAR'),
          ),
        ),
      ],
    );
  }
}