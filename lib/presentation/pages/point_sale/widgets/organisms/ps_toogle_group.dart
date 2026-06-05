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

enum MeasureType  implements ToggleOptionItem{
  unit('UNIDAD', Icons.inventory_2_outlined,'5'),
  mass('MASA', Icons.scale_outlined,'1'),
  volume('VOLUMEN', Icons.local_drink_outlined,'3'),
  length('LONGITUD', Icons.straighten_outlined,'2'),
  area('AREA', Icons.crop_square_outlined,'4');
  const MeasureType(this.value, this.icon,this.id);
  @override
  final String value;
  @override
  final String id;
  @override
  final IconData icon;
}

enum InventoryType implements ToggleOptionItem{
  raw('Materia prima', Icons.inventory_outlined,'RAW'),
  processed('Producto elaborado', Icons.restaurant_outlined,'PROCESSED'),
  forSale('Producto de venta', Icons.point_of_sale_outlined,'FOR_SALE');
  const InventoryType(this.value, this.icon,this.id);

  @override
  final String value;

  @override
  final String id;

  @override
  final IconData icon;
}

abstract class ToggleOptionItem {
  String get id;
  String get value;
  IconData get icon;
}

class PsToggleSelector<T extends ToggleOptionItem>
    extends StatelessWidget {
  final String title;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;

  const PsToggleSelector({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodySecondary(context),
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
              onTap: () => onChanged(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}