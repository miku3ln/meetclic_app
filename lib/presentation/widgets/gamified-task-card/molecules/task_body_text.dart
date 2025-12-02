import 'package:flutter/material.dart';

import '../atoms/custom_button.dart';
import '../atoms/task_description.dart';

class TaskBodyText extends StatelessWidget {
  final String description;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;
  const TaskBodyText({
    super.key,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskDescription(description: description),
        const SizedBox(height: 12),
        CustomButton(
          label: buttonText,
          color: buttonColor,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
