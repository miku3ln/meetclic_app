import 'package:flutter/material.dart';

class PosRightPanel extends StatelessWidget {
  const PosRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('RIGHT PANEL (Ticket / Totales)'),
    );
  }
}