import 'package:flutter/material.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';

class PsToggleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool enabled;
  const PsToggleOption({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);
  var colorCurrent=   (isSelected ? c.primary : c.surface);
  if(!enabled){
    colorCurrent=AppColors.shade(colorCurrent , 50);
  }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        /// 🔥 CAMBIA TAMAÑO SEGÚN ESTADO
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 40,

        decoration: BoxDecoration(
          color:colorCurrent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? c.primary : c.border,
          ),
        ),

        /// 🔥 ICONO + TEXTO DINÁMICO
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : c.textSecondary,
              size: 20,
            ),

            /// 🔥 SOLO SI ESTÁ SELECCIONADO
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}