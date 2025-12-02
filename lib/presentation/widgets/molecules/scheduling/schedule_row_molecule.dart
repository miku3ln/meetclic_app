import 'package:flutter/material.dart';
import '../../atoms/scheduling/day_text_atom.dart';
import '../../atoms/scheduling/schedule_status_atom.dart';

class ScheduleRowMolecule extends StatelessWidget {
  final String day;
  final String status;
  final bool isToday;

  const ScheduleRowMolecule({
    super.key,
    required this.day,
    required this.status,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DayTextAtom(day: day, isToday: isToday),
          ScheduleStatusAtom(status: status, isToday: isToday),
        ],
      ),
    );
  }
}
