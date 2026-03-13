import 'package:flutter/material.dart';

class PosSettingsGeneralSection extends StatefulWidget {
  const PosSettingsGeneralSection({super.key});

  @override
  State<PosSettingsGeneralSection> createState() =>
      _PosSettingsGeneralSectionState();
}

class _PosSettingsGeneralSectionState
    extends State<PosSettingsGeneralSection> {
  bool useCameraScanner = false;
  bool darkMode = false;

  String itemLayout = 'Cuadrícula';
  String languageLabel = 'Usar ajustes del dispositivo';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _SettingsSwitchTile(
          title: 'Utilice la cámara para escanear códigos de barras',
          value: useCameraScanner,
          onChanged: (value) {
            setState(() {
              useCameraScanner = value;
            });
          },
        ),
        _SettingsSwitchTile(
          title: 'Modo oscuro',
          value: darkMode,
          onChanged: (value) {
            setState(() {
              darkMode = value;
            });
          },
        ),
        _SettingsValueTile(
          title: 'Distribución de los artículos en la pantalla de inicio',
          subtitle: itemLayout,
          onTap: () {
            // abrir bottomSheet, dialog o menú
          },
        ),
        _SettingsValueTile(
          title: 'Idioma',
          subtitle: languageLabel,
          onTap: () {
            // abrir selector de idioma
          },
        ),
      ],
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingsValueTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsValueTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}