import 'package:flutter/material.dart';

class ScheduleStatusAtom extends StatelessWidget {
  final String status;
  final bool isToday;

  const ScheduleStatusAtom({super.key, required this.status, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      status,
      style: TextStyle(
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        fontSize: 16,
        color: status.toLowerCase() == "cerrado" ? Colors.grey : Colors.black,
      ),
    );
  }
}
