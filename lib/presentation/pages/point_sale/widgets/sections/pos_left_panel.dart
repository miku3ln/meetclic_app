import 'package:flutter/material.dart';

class PosLeftPanel extends StatelessWidget {
  const PosLeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('LEFT PANEL (Productos / Categorías)'),
    );
  }
}