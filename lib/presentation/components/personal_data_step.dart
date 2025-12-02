import 'package:flutter/material.dart';
import 'package:meetclic_app/aplication/controllers/user_registration_form_controller.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';

import '../widgets/atoms/date_picker_atom.dart';
import '../widgets/atoms/input_text_atom.dart';

class PersonalDataStep extends StatelessWidget {
  final UserRegistrationFormController controller;

  const PersonalDataStep({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Form(
      key: controller.formKeyStep2,
      child: Column(
        children: [
          InputTextAtom(
            label: appLocalizations.translate(
              'loginManagerTitle.register.fieldName',
            ),
            controller: controller.nombresController,
            validator: (value) => value != null && value.isNotEmpty
                ? null
                : appLocalizations.translate(
                    'loginManagerTitle.register.fieldNameInput',
                  ),
          ),
          const SizedBox(height: 12),
          InputTextAtom(
            label: appLocalizations.translate(
              'loginManagerTitle.register.fieldLastName',
            ),
            controller: controller.apellidosController,
            validator: (value) => value != null && value.isNotEmpty
                ? null
                : appLocalizations.translate(
                    'loginManagerTitle.register.fieldLastNameInput',
                  ),
          ),
          const SizedBox(height: 12),
          DatePickerAtom(
            label: appLocalizations.translate(
              'loginManagerTitle.register.fieldBirthday',
            ),
            selectedDateText: controller.fechaNacimiento == null
                ? null
                : '${controller.fechaNacimiento!.day}/${controller.fechaNacimiento!.month}/${controller.fechaNacimiento!.year}',
            onDateSelected: (picked) {
              controller.fechaNacimiento = picked;
            },
          ),
        ],
      ),
    );
  }
}
