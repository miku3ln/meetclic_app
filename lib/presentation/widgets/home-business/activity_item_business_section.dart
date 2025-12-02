import 'package:flutter/material.dart';

class ActivityItemBusiness extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  const ActivityItemBusiness({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title,style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary, // se puede personalizar desde el Theme
      )),
      subtitle: Text(subtitle,style: theme.textTheme.titleSmall?.copyWith(
        color: Colors.grey, // se puede personalizar desde el Theme
      )),
      trailing: Text(time, style: const TextStyle(color: Colors.grey)),
    );
  }
}
