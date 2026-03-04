import 'package:flutter/material.dart';

class PosSettingsCustomerScreenSection extends StatelessWidget {
  const PosSettingsCustomerScreenSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.desktop_windows, size: 72, color: Colors.black26),
            SizedBox(height: 10),
            Text(
              'Todavía no tienes pantallas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Aquí puedes conectar tu pantalla de clientes.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}