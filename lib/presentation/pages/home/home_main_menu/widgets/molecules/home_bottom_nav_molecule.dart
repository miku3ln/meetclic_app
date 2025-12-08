import 'package:flutter/material.dart';

/// Molécula que envuelve el BottomNavigationBar del Home.
///
/// Recibe:
/// - items: ítems ya construidos (átomos HomeNavItemAtom)
/// - currentIndex: índice seleccionado
/// - onTap: callback cuando el usuario cambia de tab
class HomeBottomNavMolecule extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNavMolecule({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.primary,
      selectedItemColor: theme.colorScheme.secondary,
      unselectedItemColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
    );
  }
}
