import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/models/day_schedule.dart';

import '../../widgets/atoms/scheduling/verified_label_atom.dart';
import '../../widgets/molecules/scheduling/schedule_row_molecule.dart';

class ScheduleModalOrganism extends StatelessWidget {
  final List<DaySchedule> schedule;

  const ScheduleModalOrganism({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                "Horario",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 12),
              const VerifiedLabelAtom(text: "Actualizado hace 1 Semana"),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...schedule.map(
            (item) => ScheduleAccordionMolecule(daySchedule: item),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
