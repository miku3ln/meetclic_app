import 'package:flutter/material.dart';
class TypeService {
  final String label;
  final IconData icon;
  final String value;

  TypeService({
    required this.label,
    required this.icon,
    required this.value,
  });
}
PopupMenuItem<String> BuildItemIconMenu({
  required IconData icon,
  required String text,
  required bool enabled,
  required String value,
}) {
  return PopupMenuItem<String>(
    value: enabled ? value : null,
    enabled: enabled,
    child: Row(
      children: [
        Icon(
          icon,
          color: enabled ? Colors.black54 : Colors.grey,
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    ),
  );
}
