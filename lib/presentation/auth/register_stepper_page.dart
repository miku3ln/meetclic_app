// TODO: reemplaza por tu login real cuando ya lo conectes
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../shared/localization/app_localizations.dart';
import '../../shared/themes/app_spacing.dart';
import '../widgets/atoms/date_picker_atom.dart';
import '../widgets/atoms/input_text_atom.dart';

class RegisterStepperPage extends StatefulWidget {
  const RegisterStepperPage({super.key});

  @override
  State<RegisterStepperPage> createState() => _RegisterStepperPageState();
}

class _RegisterStepperPageState extends State<RegisterStepperPage> {
  // Stepper control
  int _currentStep = 0;

  // Forms
  final formKeyStep1 = GlobalKey<FormState>();
  final formKeyStep2 = GlobalKey<FormState>();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();

  DateTime? fechaNacimiento;

  bool isStep1Valid = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    nombresController.dispose();
    apellidosController.dispose();
    super.dispose();
  }

  void onDateSelected(DateTime date) {
    setState(() {
      fechaNacimiento = date;
    });
  }

  void _validateStep1AndContinue() {
    final ok = formKeyStep1.currentState?.validate() ?? false;
    setState(() {
      isStep1Valid = ok;
      if (ok) _currentStep = 1;
    });
  }

  void _submitRegister() {
    final ok2 = formKeyStep2.currentState?.validate() ?? false;

    if (!ok2) return;

    // Aquí ya tienes:
    // emailController.text
    // passwordController.text
    // nombresController.text
    // apellidosController.text
    // fechaNacimiento
    //
    // TODO: conectar con tu register service / api
    debugPrint("REGISTER => ${emailController.text} / ${nombresController.text}");
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('loginManagerTitle.register.title')),
      ),
      body: Stepper(
        currentStep: _currentStep,
        type: StepperType.vertical,
        onStepTapped: (step) {
          // Solo permitir entrar al paso 2 si el paso 1 es válido
          if (step == 1 && !isStep1Valid) return;
          setState(() => _currentStep = step);
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 1;

          return Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (!isLast) {
                    _validateStep1AndContinue();
                  } else {
                    _submitRegister();
                  }
                },
                child: Text(
                  isLast
                      ? appLocalizations.translate('loginManagerTitle.register.buttonRegister')
                      : appLocalizations.translate('loginManagerTitle.register.buttonNext'),
                ),
              ),
              const SizedBox(width: 12),
              if (_currentStep == 1)
                TextButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  child: Text(appLocalizations.translate('loginManagerTitle.register.buttonBack')),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: Text(
              appLocalizations.translate('loginManagerTitle.register.stepOne'),
            ),
            isActive: true,
            state: isStep1Valid ? StepState.complete : StepState.indexed,
            content: Form(
              key: formKeyStep1,
              child: Column(
                children: [
                  AppSpacing.spaceBetweenInputs,
                  InputTextAtom(
                    label: appLocalizations.translate('loginManagerTitle.fieldEmail'),
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.translate('loginManagerTitle.fieldEmailInput');
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.spaceBetweenInputs,
                  InputTextAtom(
                    label: appLocalizations.translate('loginManagerTitle.fieldPassword'),
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Mínimo 6 caracteres',
                  ),
                  AppSpacing.spaceBetweenInputs,
                  InputTextAtom(
                    label: appLocalizations.translate('loginManagerTitle.register.fieldPasswordRepeat'),
                    controller: repeatPasswordController,
                    obscureText: true,
                    validator: (value) => value == passwordController.text
                        ? null
                        : appLocalizations.translate(
                      'loginManagerTitle.register.fieldPasswordRepeatError',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: Text(
              appLocalizations.translate('loginManagerTitle.register.stepTwo'),
            ),
            isActive: isStep1Valid,
            state: _currentStep == 1 ? StepState.editing : StepState.indexed,
            content: Form(
              key: formKeyStep2,
              child: Column(
                children: [
                  AppSpacing.spaceBetweenInputs,
                  InputTextAtom(
                    label: appLocalizations.translate('loginManagerTitle.register.fieldName'),
                    controller: nombresController,
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : appLocalizations.translate('loginManagerTitle.register.fieldNameInput'),
                  ),
                  AppSpacing.spaceBetweenInputs,
                  InputTextAtom(
                    label: appLocalizations.translate('loginManagerTitle.register.fieldLastName'),
                    controller: apellidosController,
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : appLocalizations.translate('loginManagerTitle.register.fieldLastNameInput'),
                  ),
                  AppSpacing.spaceBetweenInputs,
                  DatePickerAtom(
                    label: appLocalizations.translate('loginManagerTitle.register.fieldBirthday'),
                    selectedDateText: fechaNacimiento == null
                        ? null
                        : '${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
                    onDateSelected: onDateSelected,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
