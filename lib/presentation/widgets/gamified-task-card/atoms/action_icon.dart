import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  final IconData icon;
  const ActionIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 32, color: Colors.black54);
  }
}
