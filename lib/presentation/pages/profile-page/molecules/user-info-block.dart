import 'package:flutter/material.dart';
import '../../../../shared/providers_session.dart';

class UserInfoBlock extends StatelessWidget {
  const UserInfoBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = Provider.of<SessionService>(
      context,
    ); // ✅ Reactivo: escucha cambios
    var userData = session.currentSession;
    var fullName = (userData?.personId != null)
        ? "${userData?.personName ?? ''} ${userData?.lastName ?? ''}".trim()
        : 'No Gestionado';
    return Column(
      children: [
        Text(fullName,
            style: TextStyle(color: theme.primaryColor)),
        const SizedBox(height: 4),
        Text('@MIGUELAlba356038', style: TextStyle(color: theme.colorScheme.surface)),
        const SizedBox(height: 4),
        Text('Miembro desde Mayo 2025', style: TextStyle(color: theme.colorScheme.onBackground)),
      ],
    );
  }
}
