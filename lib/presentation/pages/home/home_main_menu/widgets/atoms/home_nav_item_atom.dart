import 'package:flutter/material.dart';

/// Átomo responsable de construir un BottomNavigationBarItem
/// para el menú principal.
///
/// Se usa en HomeTabFactory.navItemBuilder para mantener
/// un estilo consistente y centralizar posibles cambios.
class HomeNavItemAtom {
  const HomeNavItemAtom._(); // evita instanciación

  static BottomNavigationBarItem build({
    required IconData icon,
    required String label,
  }) {
    return BottomNavigationBarItem(icon: Icon(icon), label: label);
  }
}
