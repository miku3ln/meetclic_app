import 'package:flutter/material.dart';

class ManagerProcessMicroConfig {
  final String title;
  final String? description;
  final IconData icon;

  final String submitText;
  final String cancelText;

  final double maxWidth;

  const ManagerProcessMicroConfig({
    required this.title,
    this.description,
    this.icon = Icons.settings_rounded,
    this.submitText = 'Guardar',
    this.cancelText = 'Cancelar',
    this.maxWidth = 430,
  });
}