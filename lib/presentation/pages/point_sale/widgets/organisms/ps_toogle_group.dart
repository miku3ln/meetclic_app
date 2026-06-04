import 'package:flutter/material.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../molecules/ps_toogle_option.dart';
enum TypeDesgloce {

  processedRecipe(
    'RECETA-PROCESADA',
    'RECETA',
    Icons.restaurant_menu_outlined,
  ),

  menuRecipe(
    'RECETA-MENU',
    'MENU',
    Icons.menu_book_outlined,
  );

  const TypeDesgloce(
      this.code,
      this.label,
      this.icon,
      );

  final String code;    // valor interno
  final String label;   // texto visible
  final IconData icon;  // icono
}

enum MeasureType {
  mass('MASA', Icons.scale_outlined,'1'),
  unit('UNIDAD', Icons.inventory_2_outlined,'5'),
  volume('VOLUMEN', Icons.local_drink_outlined,'3'),
  length('LONGITUD', Icons.straighten_outlined,'2'),
  area('AREA', Icons.crop_square_outlined,'4');

  const MeasureType(this.value, this.icon,this.id);

  final String value;
  final String id;

  final IconData icon;
}

class PsSellTypeSelector extends StatelessWidget {
  final MeasureType value;
  final Function(MeasureType) onChanged;

  const PsSellTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tipo de Medida:", style: AppTextStyles.bodySecondary(context)),
        AppSpacing.spaceBetweenInputs,
        Row(
          children: [
            PsToggleOption(
              icon: MeasureType.unit.icon,
              label: MeasureType.unit.value,
              isSelected: value == MeasureType.unit,
              onTap: () => onChanged(MeasureType.unit),
            ),
            const SizedBox(width: 8),

            PsToggleOption(
              icon: MeasureType.mass.icon,
              label: MeasureType.mass.value,
              isSelected: value == MeasureType.mass,
              onTap: () => onChanged(MeasureType.mass),
            ),

            const SizedBox(width: 8),

            PsToggleOption(
              icon: MeasureType.volume.icon,
              label: MeasureType.volume.value,
              isSelected: value == MeasureType.volume,
              onTap: () => onChanged(MeasureType.volume),
            ),
            const SizedBox(width: 8),

            PsToggleOption(
              icon: MeasureType.length.icon,
              label: MeasureType.length.value,
              isSelected: value == MeasureType.length,
              onTap: () => onChanged(MeasureType.length),
            ),
            const SizedBox(width: 8),

            PsToggleOption(
              icon: MeasureType.area.icon,
              label: MeasureType.area.value,
              isSelected: value == MeasureType.area,
              onTap: () => onChanged(MeasureType.area),
            ),

          ],
        ),
      ],
    );
  }
}
