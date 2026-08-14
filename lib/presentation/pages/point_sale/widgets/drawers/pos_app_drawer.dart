import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/services/session_service.dart';
import '../../../../../app/router/controllers/app_controller.dart';
import '../../../../../app/router/controllers/app_drawer_controller.dart';
class PosAppDrawer extends StatelessWidget {

  const PosAppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final drawer = context.watch<AppDrawerController>();
    final session = context.watch<SessionService>();
    final app = context.read<AppController>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  session.displayName.isNotEmpty
                      ? session.displayName[0].toUpperCase()
                      : '?',
                ),
              ),
              title: Text(
                session.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(session.displayEmail),
              trailing: const Icon(
                Icons.arrow_drop_down,
              ),
              onTap: () {},
            ),

            if (session.displayBusiness.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${session.displayBusiness} • ${session.displayRole}',
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

            const Divider(height: 1),

            // =========================
            // MENU
            // =========================
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final item in drawer.items)
                    _buildDrawerItem(
                      context,
                      drawer,
                      app,
                      item,
                    ),
                ],
              ),
            ),

            // =========================
            // LOGOUT
            // =========================
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('CERRAR SESIÓN'),
                  onPressed: () => app.logout(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
Widget _buildDrawerItem(
    BuildContext context,
    AppDrawerController drawer,
    AppController app,
    AppDrawerItem item,
    ) {
  if (item.hasChildren) {
    return ExpansionTile(
      key: PageStorageKey(item.id),

      initiallyExpanded: drawer.isExpanded(item.id),

      onExpansionChanged: (expanded) {
        drawer.setExpanded(
          item.id,
          expanded,
        );
      },

      leading: Icon(item.icon),

      title: Text(
        item.title,
      ),

      children: [
        for (final child in item.children)
          ListTile(
            contentPadding: const EdgeInsets.only(
              left: 56,
              right: 16,
            ),
            leading: Icon(
              child.icon,
              size: 20,
            ),
            title: Text(
              child.title,
            ),
            selected: app.isCurrentDrawerItem(child),
            onTap: () {
              drawer.onItemTap(
                context,
                child,
              );
            },
          ),
      ],
    );
  }

  return ListTile(
    leading: Icon(item.icon),
    title: Text(item.title),
    selected: app.isCurrentDrawerItem(item),
    onTap: () {
      drawer.onItemTap(
        context,
        item,
      );
    },
  );
}