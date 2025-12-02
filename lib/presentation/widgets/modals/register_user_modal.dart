import 'package:flutter/material.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';
import 'package:meetclic_app/presentation/widgets/atoms/button_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/date_picker_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/input_text_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/intro_logo.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/themes/app_spacing.dart';

Widget buildRegisterStepperView({
  required AppLocalizations appLocalizations,
  required ThemeData theme,
  required int currentStep,
  required bool isStep1Valid,
  required bool isStep2Valid,
  required GlobalKey<FormState> formKeyStep1,
  required GlobalKey<FormState> formKeyStep2,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController repeatPasswordController,
  required TextEditingController nombresController,
  required TextEditingController apellidosController,
  required DateTime? fechaNacimiento,
  required void Function(DateTime picked) onDateSelected,
  required void Function() nextStep,
  required void Function() previousStep,
  required void Function(int index) onStepTapped,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        appLocalizations.translate('loginManagerTitle.register.title'),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Center(child: IntroLogo(assetPath: AppImages.pageLoginInit, height: 250)),
      const SizedBox(height: 16),
      Stepper(
        physics: const ClampingScrollPhysics(),
        type: StepperType.vertical,
        currentStep: currentStep,
        onStepTapped: (index) => onStepTapped(index),
        controlsBuilder: (context, _) => const SizedBox.shrink(),
        steps: buildRegistrationSteps(
          appLocalizations: appLocalizations,
          formKeyStep1: formKeyStep1,
          formKeyStep2: formKeyStep2,
          emailController: emailController,
          passwordController: passwordController,
          repeatPasswordController: repeatPasswordController,
          nombresController: nombresController,
          apellidosController: apellidosController,
          fechaNacimiento: fechaNacimiento,
          isStep1Valid: isStep1Valid,
          onDateSelected: onDateSelected,
        ),
      ),
      Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: ButtonAtom(
                text: appLocalizations.translate(
                  'loginManagerTitle.register.buttonBack',
                ),
                onPressed: previousStep,
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ButtonAtom(
              backgroundColor: isStep1Valid && isStep2Valid
                  ? theme.colorScheme.primary
                  : theme.disabledColor,
              text: currentStep == 1
                  ? appLocalizations.translate(
                      'loginManagerTitle.register.buttonRegister',
                    )
                  : appLocalizations.translate(
                      'loginManagerTitle.register.buttonNext',
                    ),
              onPressed: nextStep,
            ),
          ),
        ],
      ),
    ],
  );
}

List<Step> buildRegistrationSteps({
  required AppLocalizations appLocalizations,
  required GlobalKey<FormState> formKeyStep1,
  required GlobalKey<FormState> formKeyStep2,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController repeatPasswordController,
  required TextEditingController nombresController,
  required TextEditingController apellidosController,
  required DateTime? fechaNacimiento,
  required bool isStep1Valid,
  required void Function(DateTime picked) onDateSelected,
}) {
  return [
    Step(
      title: Text(
        appLocalizations.translate('loginManagerTitle.register.stepOne'),
      ),
      isActive: true,
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
                  return appLocalizations.translate(
                    'loginManagerTitle.fieldEmailInput',
                  );
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            AppSpacing.spaceBetweenInputs,
            InputTextAtom(
              label: appLocalizations.translate(
                'loginManagerTitle.fieldPassword',
              ),
              controller: passwordController,
              obscureText: true,
              validator: (value) => value != null && value.length >= 6
                  ? null
                  : 'Mínimo 6 caracteres',
            ),
            AppSpacing.spaceBetweenInputs,
            InputTextAtom(
              label: appLocalizations.translate(
                'loginManagerTitle.register.fieldPasswordRepeat',
              ),
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
      content: Form(
        key: formKeyStep2,
        child: Column(
          children: [
            AppSpacing.spaceBetweenInputs,
            InputTextAtom(
              label: appLocalizations.translate(
                'loginManagerTitle.register.fieldName',
              ),
              controller: nombresController,
              validator: (value) => value != null && value.isNotEmpty
                  ? null
                  : appLocalizations.translate(
                      'loginManagerTitle.register.fieldNameInput',
                    ),
            ),
            AppSpacing.spaceBetweenInputs,
            InputTextAtom(
              label: appLocalizations.translate(
                'loginManagerTitle.register.fieldLastName',
              ),
              controller: apellidosController,
              validator: (value) => value != null && value.isNotEmpty
                  ? null
                  : appLocalizations.translate(
                      'loginManagerTitle.register.fieldLastNameInput',
                    ),
            ),
            AppSpacing.spaceBetweenInputs,
            DatePickerAtom(
              label: appLocalizations.translate(
                'loginManagerTitle.register.fieldBirthday',
              ),
              selectedDateText: fechaNacimiento == null
                  ? null
                  : '${fechaNacimiento.day}/${fechaNacimiento.month}/${fechaNacimiento.year}',
              onDateSelected: onDateSelected,
            ),
          ],
        ),
      ),
    ),
  ];
}

class UserRegistrationModel {
  final String email;
  final String password;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;

  UserRegistrationModel({
    //HOLA
    required this.email,
    required this.password,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
  });
}

// ✅ Modal trigger con función que recibe context y modelo
void showRegisterUserModal(
  BuildContext context,
  Future<bool> Function(BuildContext, UserRegistrationModel) onSubmit,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (contextModal) => FractionallySizedBox(
      heightFactor: 0.95,
      child: _RegisterUserModal(onSubmit: onSubmit),
    ),
  );
}

// ✅ Modal corregido
class _RegisterUserModal extends StatefulWidget {
  final Future<bool> Function(BuildContext, UserRegistrationModel) onSubmit;

  const _RegisterUserModal({required this.onSubmit});

  @override
  State<_RegisterUserModal> createState() => _RegisterUserModalState();
}

class _RegisterUserModalState extends State<_RegisterUserModal> {
  int currentStep = 0;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();

  DateTime? fechaNacimiento;

  bool get isStep1Valid =>
      _formKeyStep1.currentState?.validate() == true &&
      passwordController.text == repeatPasswordController.text;

  bool get isStep2Valid =>
      _formKeyStep2.currentState?.validate() == true && fechaNacimiento != null;

  Future<void> nextStep() async {
    if (currentStep == 0 && isStep1Valid) {
      setState(() => currentStep = 1);
    } else if (currentStep == 1 && isStep2Valid) {
      final shouldClose = await widget.onSubmit(
        context,
        UserRegistrationModel(
          email: emailController.text,
          password: passwordController.text,
          nombres: nombresController.text,
          apellidos: apellidosController.text,
          fechaNacimiento: fechaNacimiento!,
        ),
      );
      if (shouldClose) {
        Navigator.pop(context);
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: buildRegisterStepperView(
                  appLocalizations: appLocalizations,
                  theme: theme,
                  currentStep: currentStep,
                  isStep1Valid: isStep1Valid,
                  isStep2Valid: isStep2Valid,
                  formKeyStep1: _formKeyStep1,
                  formKeyStep2: _formKeyStep2,
                  emailController: emailController,
                  passwordController: passwordController,
                  repeatPasswordController: repeatPasswordController,
                  nombresController: nombresController,
                  apellidosController: apellidosController,
                  fechaNacimiento: fechaNacimiento,
                  onDateSelected: (picked) =>
                      setState(() => fechaNacimiento = picked),
                  nextStep: nextStep,
                  previousStep: previousStep,
                  onStepTapped: (index) {
                    if (index == 1 && isStep1Valid) {
                      setState(() => currentStep = 1);
                    } else if (index == 0) {
                      setState(() => currentStep = 0);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
