import 'package:flutter/material.dart';

class HomeDrawerWidget extends StatelessWidget {
  const HomeDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: theme.colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Text(
              'Unit Menu',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(Icons.play_arrow, color: colorScheme.primary),
            title: Text(
              'Start Lesson',
              style: TextStyle(color: colorScheme.primary, fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(Icons.history, color: colorScheme.primary),
            title: Text(
              'Progress',
              style: TextStyle(color: colorScheme.primary, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
