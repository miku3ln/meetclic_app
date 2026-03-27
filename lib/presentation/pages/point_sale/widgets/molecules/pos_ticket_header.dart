import 'package:flutter/material.dart';

import '../../shared/utils.dart';
import '../layouts/tablet_landscape/pos_tablet_landscape_controller.dart'; //oki

class TypeServiceDropdown extends StatelessWidget {
  final List<TypeService> items;
  final TypeService selected;
  final Function(TypeService) onSelected;

  const TypeServiceDropdown({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await showMenu<TypeService>(
          context: context,
          position: const RelativeRect.fromLTRB(150, 100, 20, 0),
          items: items.map((tipo) {
            return PopupMenuItem<TypeService>(
              value: tipo,
              child: Row(
                children: [
                  Icon(tipo.icon, color: Colors.black54),
                  const SizedBox(width: 12),
                  Text(tipo.label),
                ],
              ),
            );
          }).toList(),
        );

        if (result != null) {
          onSelected(result); // 🔥 delegas al padre
        }
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max, // 👈 CLAVE
          children: [
            Icon(selected.icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),

            Expanded(
              // 👈 CLAVE
              child: Text(selected.label, overflow: TextOverflow.ellipsis),
            ),

            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class PosTicketHeader extends StatefulWidget {
  final String title;
  final int itemsCount;

  final PosTabletLandscapeController controllerMain;

  const PosTicketHeader({
    super.key,
    required this.title,
    required this.itemsCount,
    required this.controllerMain,
  });

  @override
  State<PosTicketHeader> createState() => _PosTicketHeaderState();
}

class _PosTicketHeaderState extends State<PosTicketHeader> {
  late List<TypeService> tipos;
  late TypeService selected;

  @override
  void initState() {
    super.initState();
    tipos=   widget.controllerMain.typeServicesData;
    selected =widget.controllerMain.typeService;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // 👈 🔥 CLAVE
          child: TypeServiceDropdown(
            items: tipos,
            selected: selected,
            onSelected: (value) {
              setState(() {
                selected = value;
              });
              widget.controllerMain.setTypeService(value);
              debugPrint('Seleccionado: ${value.value}');
            },
          ),
        ),
      ],
    );
  }
}
