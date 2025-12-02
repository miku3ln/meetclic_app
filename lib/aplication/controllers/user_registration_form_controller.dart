import 'package:flutter/material.dart';
import '../../../domain/models/user_registration_model.dart';

class UserRegistrationFormController {
  final formKeyStep1 = GlobalKey<FormState>();
  final formKeyStep2 = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();

  DateTime? fechaNacimiento;

  bool get isStep1Valid =>
      formKeyStep1.currentState?.validate() == true &&
      passwordController.text == repeatPasswordController.text;

  bool get isStep2Valid =>
      formKeyStep2.currentState?.validate() == true && fechaNacimiento != null;

  UserRegistrationLoginModel buildUser() {
    return UserRegistrationLoginModel(
      email: emailController.text,
      password: passwordController.text,
      name: nombresController.text,
      last_name: apellidosController.text,
      birthdate: fechaNacimiento!,
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    nombresController.dispose();
    apellidosController.dispose();
  }
}
