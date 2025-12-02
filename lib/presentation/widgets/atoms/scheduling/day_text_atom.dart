import 'package:flutter/material.dart';

class DayTextAtom extends StatelessWidget {
  final String day;
  final bool isToday;

  const DayTextAtom({super.key, required this.day, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: TextStyle(
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        fontSize: 16,
      ),
    );
  }
}
