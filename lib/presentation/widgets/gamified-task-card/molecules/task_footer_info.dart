import 'package:flutter/material.dart';

class TaskFooterInfo extends StatelessWidget {
  final String sponsor;
  final String endDate;
  const TaskFooterInfo({
    super.key,
    required this.sponsor,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Auspiciado por: $sponsor',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          'Finaliza: $endDate',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.red),
        ),
      ],
    );
  }
}
