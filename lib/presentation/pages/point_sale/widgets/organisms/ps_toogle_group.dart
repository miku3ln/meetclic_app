import 'package:flutter/material.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../shared/theme/configuration/app_theme_tokens.dart';
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

enum MeasureType  implements ToggleOptionItem{
  unit('UNIDAD', Icons.inventory_2_outlined,'5',Colors.cyan),
  mass('MASA', Icons.scale_outlined,'1',Colors.amber),
  volume('VOLUMEN', Icons.local_drink_outlined,'3',Colors.blue),
  length('LONGITUD', Icons.straighten_outlined,'2',Colors.grey),
  area('AREA', Icons.crop_square_outlined,'4',Colors.brown);
  const MeasureType(this.value, this.icon,this.id,this.color);
  @override
  final String value;
  @override
  final String id;
  @override
  final IconData icon;

  @override
  final Color color;
}

enum InventoryType implements ToggleOptionItem{
  raw('Materia prima', Icons.inventory_outlined,'RAW',Colors.grey),
  processed('Elaborado', Icons.restaurant_outlined,'PROCESSED',Colors.blueAccent),
  forSale('Menu', Icons.point_of_sale_outlined,'FOR_SALE',Colors.amber);
  const InventoryType(this.value, this.icon,this.id,this.color);

  @override
  final String value;

  @override
  final String id;

  @override
  final IconData icon;

  @override
  final Color color;
}

abstract class ToggleOptionItem {
  String get id;
  String get value;
  IconData get icon;
  Color get color;

}

class PsToggleSelector<T extends ToggleOptionItem>
    extends StatelessWidget {
  final String title;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final bool enabled;

  const PsToggleSelector({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodySecondary(context).copyWith(
            color: enabled ? null : c.textDisabled,
          ),
        ),

        AppSpacing.spaceBetweenInputs,

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return PsToggleOption(
              icon: item.icon,
              label: item.value,
              isSelected: item == value,
              enabled: enabled,
              onTap: enabled
                  ? () => onChanged(item)
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}