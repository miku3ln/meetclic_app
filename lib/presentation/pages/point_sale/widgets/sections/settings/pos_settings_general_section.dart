import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_controller.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

class PosSettingsGeneralSection extends StatefulWidget {
  const PosSettingsGeneralSection({super.key});

  @override
  State<PosSettingsGeneralSection> createState() =>
      _PosSettingsGeneralSectionState();
}

class _PosSettingsGeneralSectionState
    extends State<PosSettingsGeneralSection> {
  bool useCameraScanner = false;

  String itemLayout = 'Cuadrícula';
  String languageLabel = 'Usar ajustes del dispositivo';

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeTokens.of(context);
    final themeController = context.watch<AppThemeController>();

    final isDarkMode = themeController.themeMode == ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
          value: isDarkMode,
          onChanged: (value) {
            if (value) {
              themeController.setDark();
            } else {
              themeController.setLight();
            }
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
    final colors = AppThemeTokens.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      title: Text(
        title,
        style: AppTextStyles.body(context).copyWith(
          fontSize: 18,
          color: colors.textPrimary,
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
    final colors = AppThemeTokens.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      title: Text(
        title,
        style: AppTextStyles.body(context).copyWith(
          fontSize: 18,
          color: colors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          subtitle,
          style: AppTextStyles.bodySecondary(context).copyWith(
            fontSize: 15,
            color: colors.textSecondary,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}