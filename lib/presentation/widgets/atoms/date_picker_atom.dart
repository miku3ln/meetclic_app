import 'package:flutter/material.dart';
import 'date_picker_atom_config.dart';

class DatePickerAtom extends StatelessWidget {
  final String label;
  final String? selectedDateText;
  final ValueChanged<DateTime> onDateSelected;
  final DatePickerAtomConfig? config;  // Puede ser null

  const DatePickerAtom({
    required this.label,
    this.selectedDateText,
    required this.onDateSelected,
    this.config,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Si config no viene, usar defaultConfig
    final DatePickerAtomConfig effectiveConfig = config ?? DatePickerAtomConfig.defaultConfig;

    return Container(
      color: effectiveConfig.backgroundColor,
      child: ListTile(
        title: Text(label, style: effectiveConfig.labelStyle),
        subtitle: Text(
          selectedDateText ?? 'Seleccionar fecha',
          style: effectiveConfig.textStyle,
        ),
        trailing: Icon(Icons.calendar_today, color: effectiveConfig.iconColor),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Dialog(
                backgroundColor: effectiveConfig.backgroundColor,
                child: child!,
              );
            },
          );

          if (picked != null) {
            onDateSelected(picked);
          }
        },
      ),
    );
  }
}
