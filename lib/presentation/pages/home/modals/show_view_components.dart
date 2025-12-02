import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/widgets/atoms/button_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/checkbox_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/date_picker_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/dropdown_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/input_text_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/label_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/switch_toggle_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/title_atom.dart';

void showViewComponents(
  BuildContext context,
  Function(Map<String, String>) onSubmit,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _ViewComponentsModal(onSubmit: onSubmit),
  );
}

class _ViewComponentsModal extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;

  const _ViewComponentsModal({required this.onSubmit});

  @override
  State<_ViewComponentsModal> createState() => _ViewComponentsModalState();
}

class _ViewComponentsModalState extends State<_ViewComponentsModal> {
  int currentStep = 0;
  final Map<String, String> formData = {};

  String selectedDropdown = 'Opción 1';
  bool switchValue = false;
  bool checkboxValue = false;
  String? selectedDate;

  final TextEditingController input1Controller = TextEditingController();
  final TextEditingController input2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleAtom(text: 'Componentes Átomos'),
            SizedBox(height: 16),
            if (currentStep == 0) ...[
              LabelAtom(text: 'Paso 1️⃣ - Icono'),
              InputTextAtom(
                label: 'Correo',
                onChanged: (value) => formData['correo'] = value,
              ),
              SizedBox(height: 12),
              InputTextAtom(
                label: 'Contraseña',
                obscureText: true,
                onChanged: (value) => formData['password'] = value,
              ),
              SizedBox(height: 12),
              DropdownAtom(
                label: 'Selecciona una opción',
                items: ['Opción 1', 'Opción 2', 'Opción 3'],
                value: selectedDropdown,
                onChanged: (value) {
                  setState(() {
                    selectedDropdown = value ?? 'Opción 1';
                    formData['dropdown'] = selectedDropdown;
                  });
                },
              ),
              SizedBox(height: 12),
              SwitchToggleAtom(
                value: switchValue,
                onChanged: (value) {
                  setState(() {
                    switchValue = value;
                    formData['switch'] = value.toString();
                  });
                },
              ),
            ] else if (currentStep == 1) ...[
              LabelAtom(text: 'Paso 2️⃣ - Equino'),
              InputTextAtom(
                label: 'Nombre del Caballo',
                onChanged: (value) => formData['nombreCaballo'] = value,
              ),
              SizedBox(height: 12),
              DatePickerAtom(
                label: 'Fecha de Nacimiento',
                selectedDateText: selectedDate,
                onDateSelected: (picked) {
                  setState(() {
                    selectedDate = '${picked.toLocal()}'.split(' ')[0];
                    formData['fechaNacimiento'] = selectedDate!;
                  });
                },
              ),
              SizedBox(height: 12),
              CheckboxAtom(
                value: checkboxValue,
                label: LabelAtom(text: '¿Es pura sangre?'),
                onChanged: (value) {
                  setState(() {
                    checkboxValue = value ?? false;
                    formData['puraSangre'] = checkboxValue.toString();
                  });
                },
              ),
            ],
            SizedBox(height: 20),
            Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: ButtonAtom(
                      text: 'Atrás',
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                    ),
                  ),
                SizedBox(width: 8),
                if (currentStep < 1)
                  Expanded(
                    child: ButtonAtom(
                      text: 'Siguiente',
                      onPressed: () {
                        setState(() {
                          currentStep++;
                        });
                      },
                    ),
                  )
                else
                  Expanded(
                    child: ButtonAtom(
                      text: 'Guardar',
                      onPressed: () {
                        widget.onSubmit(formData);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
