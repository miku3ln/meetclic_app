import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/business_data.dart';

import 'task_card_business_section.dart';

class TaskListBusinessSection extends StatelessWidget {
  final BusinessData businessData;
  const TaskListBusinessSection({super.key, required this.businessData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: const [
          Expanded(
            child: TaskCardBusiness(
              icon: Icons.medical_services,
              title: 'Take the medicine',
              subtitle: '3 times a day',
              percent: 0.33,
              accentColor: Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TaskCardBusiness(
              icon: Icons.music_note,
              title: 'Music lesson',
              subtitle: 'The sixth string',
              percent: 0.0,
              accentColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
