import 'package:flutter/material.dart';
import 'custom_tag_button.dart';

class CustomFilterGroup extends StatefulWidget {
  final String title;
  final List<String> options;

  const CustomFilterGroup({
    super.key,
    required this.title,
    required this.options,
  });

  @override
  State<CustomFilterGroup> createState() => _CustomFilterGroupState();
}

class _CustomFilterGroupState extends State<CustomFilterGroup> {
  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle titleStyle =TextStyle(
      color: theme.primaryColor,
      fontSize:18,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title,
            style: titleStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.options.map((option) {
            return CustomTagButton(
              text: option,
              isSelected: selected.contains(option),
              onTap: () {
                setState(() {
                  if (selected.contains(option)) {
                    selected.remove(option);
                  } else {
                    selected.add(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
