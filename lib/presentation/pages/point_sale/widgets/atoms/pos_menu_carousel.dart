import 'package:flutter/material.dart';
import '../atoms/pos_menu_chip_button.dart';
import '../models/pos_action_item.dart';

class PosMenuCarousel extends StatelessWidget {
  final List<PosMenuActionItem> items;
  final String? selectedId;
  final ValueChanged<String> onTap;

  const PosMenuCarousel({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Scrollbar(
      thumbVisibility: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((a) {
            final bool isActive = a.id == selectedId;
            final bool isGrid = a.id == 'grid';

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: PosMenuChipButton(
                label: a.value,
                enabled: a.enabled,
                active: isActive,
                compact: isGrid,
                onTap: a.enabled ? () => onTap(a.id) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}