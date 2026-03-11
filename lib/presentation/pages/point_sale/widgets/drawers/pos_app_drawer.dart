import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/services/session_service.dart';
import '../../../../../shared/controllers/app_controller.dart';
import '../../../../../shared/controllers/app_drawer_controller.dart';


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
            ListTile(
              leading: CircleAvatar(
                child: Text(session.displayName.isNotEmpty
                    ? session.displayName[0].toUpperCase()
                    : '?'),
              ),
              title: Text(session.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(session.displayEmail),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () {},
            ),
            if (session.displayBusiness.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${session.displayBusiness} • ${session.displayRole}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            const Divider(height: 1),

            for (final item in drawer.items)
              ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                selected: drawer.selectedId == item.id,
                onTap: () => drawer.onItemTap(context,item),
              ),

            const Spacer(),
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