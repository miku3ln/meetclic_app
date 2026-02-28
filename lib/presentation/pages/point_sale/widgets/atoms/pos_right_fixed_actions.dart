import 'package:flutter/material.dart';

import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart';

class PosRightFixedActions extends StatelessWidget {
  final PosTabletLandscapeController controller;

  final VoidCallback onSave;
  final VoidCallback onPay;
  const PosRightFixedActions({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onPay,

  });

  @override
  Widget build(BuildContext context) {
    final bool allowProcess = controller.ticketItems.isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: allowProcess ? onSave : null,
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
            onPressed: allowProcess ? onPay : null,
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