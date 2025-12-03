import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/models/user_login.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';
import 'package:meetclic_app/presentation/widgets/atoms/input_text_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/intro_logo.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/themes/app_spacing.dart';

import '../../../domain/models/api_response_model.dart';

/// Callback estándar: retorna bool indicando éxito del login
typedef LoginActionCallback =
    Future<ApiResponseModel<Map<String, dynamic>>> Function(
      BuildContext context,
      UserLoginModel model,
    );

/// Modal que devuelve un bool (login exitoso o fallido)
Future<bool> showLoginUserModal(
  BuildContext context,
  LoginActionCallback onLoginSubmit,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => LoginModalContent(onLoginSubmit: onLoginSubmit),
  );

  return result == true;
}

/// Contenido del modal de login
class LoginModalContent extends StatefulWidget {
  final LoginActionCallback onLoginSubmit;

  const LoginModalContent({required this.onLoginSubmit, super.key});

  @override
  State<LoginModalContent> createState() => _LoginModalContentState();
}

class _LoginModalContentState extends State<LoginModalContent> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isButtonEnabled = false;
  bool isLoading = false;

  // 🔹 Estado del ALERT / BADGE
  String? _alertMessage;
  Color? _alertBackgroundColor;
  Color? _alertTextColor;
  IconData? _alertIcon;

  @override
  void initState() {
    super.initState();
    emailController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  void validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final emailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    final passwordValid = password.length >= 6;

    setState(() {
      isButtonEnabled = emailValid && passwordValid;
    });
  }

  Future<void> handleLogin() async {
    if (!isButtonEnabled) return;
    final theme = Theme.of(context);

    setState(() {
      isLoading = true;
      _alertMessage = "Validando tus datos, por favor espera…";
      _alertBackgroundColor = theme.colorScheme.primary.withOpacity(0.08);
      _alertTextColor = theme.colorScheme.onSurface;
      _alertIcon = Icons.info_outline;
    });

    final model = UserLoginModel(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final result = await widget.onLoginSubmit(context, model);

    setState(() => isLoading = false);

    if (result.success) {
      setState(() {
        _alertMessage = "¡Inicio de sesión exitoso!";
        _alertBackgroundColor = Colors.green.withOpacity(0.1);
        _alertTextColor = Colors.green[800];
        _alertIcon = Icons.check_circle_outline;
      });
      Navigator.pop(context, true);
      // ✅ Cierra modal si login fue exitoso
    } else {
      setState(() {
        isLoading = false;
        _alertMessage = result.message;
        _alertBackgroundColor = Colors.red.withOpacity(0.08);
        _alertTextColor = Colors.red[800];
        _alertIcon = Icons.error_outline;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //LOGIN FORM
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      reverse: true, // 👈 Asegura que al escribir se enfoque hacia abajo
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 32,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            32, // 👈 Espacio para el teclado
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntroLogo(assetPath: AppImages.pageLoginInit, height: 200),
              // 🔹 ALERTA / BADGE ANTES DEL CORREO
              if (_alertMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _alertBackgroundColor ??
                        theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _alertIcon ?? Icons.info_outline,
                        size: 20,
                        color: _alertTextColor ?? theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _alertMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                _alertTextColor ?? theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.spaceBetweenInputs,
              ],
              AppSpacing.spaceBetweenInputs,
              InputTextAtom(
                label: appLocalizations.translate(
                  'loginManagerTitle.fieldEmail',
                ),
                controller: emailController,
              ),
              AppSpacing.spaceBetweenInputs,
              InputTextAtom(
                label: appLocalizations.translate(
                  'loginManagerTitle.fieldPassword',
                ),
                controller: passwordController,
                obscureText: true,
              ),
              AppSpacing.spaceBetweenInputs,
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isButtonEnabled && !isLoading ? handleLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          appLocalizations.translate(
                            'loginManagerTitle.singInButton',
                          ),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
