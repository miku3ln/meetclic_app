import 'package:flutter/material.dart';
import '../templates/pos_split_template.dart';
import '../slots/pos_layout_slots.dart';

import '../organisms/pos_header_bar.dart';
import '../sections/pos_left_panel.dart';
import '../sections/pos_right_panel.dart';
import '../sections/pos_action_bar.dart';
import '../models/pos_action_item.dart';

class PosTabletLandscapeLayout extends StatefulWidget {
  const PosTabletLandscapeLayout({super.key});

  @override
  State<PosTabletLandscapeLayout> createState() =>
      _PosTabletLandscapeLayoutState();
}

class _PosTabletLandscapeLayoutState extends State<PosTabletLandscapeLayout> {
  bool _isShiftOpen = false;

  Future<void> _openShift(double initialCash) async {
    // ✅ AQUÍ VA TU LÓGICA VIEJA REAL:
    // - llamar service / provider / bloc
    // - guardar caja abierta + efectivo inicial
    // - etc.

    debugPrint('OPEN SHIFT => initialCash: $initialCash');

    setState(() => _isShiftOpen = true); // ✅ refresca el panel
  }

  @override
  Widget build(BuildContext context) {
    return PosSplitTemplate(
      slots: PosLayoutSlots(
        header: PosHeaderBar(
          dropdownItems: const ['Todos los artículos'],
          selectedItem: 'Todos los artículos',
          onMenuTap: () {},
          onUserTap: () {},
          onMoreTap: () {},
          onDropdownChanged: (_) {},
          onSearchChanged: (q) => debugPrint('SEARCH CHANGED => $q'),
          onSearchSubmitted: (q) => debugPrint('SEARCH SUBMIT => $q'),
        ),

        left: PosLeftPanel(isShiftOpen: _isShiftOpen, onOpenShift: _openShift),

        right: const PosRightPanel(),

        footer: PosActionBar(
          leftActions: [
            PosActionItem(id: 'menu', name: 'Menu', onTap: () {}),
            PosActionItem(
              id: 'bebidas-calientes',
              name: 'Bebidas Calientes',
              onTap: () {},
            ),
            PosActionItem(
              id: 'bebidas-frias',
              name: 'Bebidas Frias',
              onTap: () {},
            ),
            PosActionItem(id: 'postres', name: 'Postres', onTap: () {}),
            PosActionItem(id: 'combos', name: 'Combos', onTap: () {}),
            PosActionItem(id: 'promociones', name: 'Promociones', onTap: () {}),
            PosActionItem(id: 'fast-food', name: 'Hamburgesas', onTap: () {}),
            PosActionItem(
              id: 'bebidas',
              name: 'Bebidas y adicional',
              onTap: () {},
            ),
            PosActionItem(id: 'grid', name: '▦', onTap: () {}),
          ],
          onSave: () {},
          onPay: () {},
        ),
      ),
    );
  }
}
