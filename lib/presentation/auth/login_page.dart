import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:meetclic_app/presentation/auth/register_stepper_page.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';
import 'package:meetclic_app/shared/localization/app_localizations.dart';
import 'package:meetclic_app/shared/themes/app_spacing.dart';

import 'package:meetclic_app/presentation/widgets/atoms/input_text_atom.dart';
import 'package:meetclic_app/presentation/widgets/atoms/intro_logo.dart';

import 'package:meetclic_app/domain/services/session_service.dart';
import 'package:meetclic_app/domain/services/fake_auth_service.dart';

import '../pages/splash_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isButtonEnabled = true;

  // Alert UI
  String? _alertMessage;
  Color? _alertBackgroundColor;
  Color? _alertTextColor;
  IconData? _alertIcon;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showAlert({
    required String message,
    IconData icon = Icons.info_outline,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    setState(() {
      _alertMessage = message;
      _alertIcon = icon;
      _alertBackgroundColor =
          backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.5);
      _alertTextColor = textColor ?? theme.colorScheme.onSurface;
    });
  }

  Future<void> handleLogin() async {
    final appLocalizations = AppLocalizations.of(context);

    final email = emailController.text.trim();
    final pass = passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      _showAlert(
        message: appLocalizations.translate('loginManagerTitle.fieldEmailInput'),
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userData = await FakeAuthService().login(
        email: email,
        password: pass,
      );

      await context.read<SessionService>().saveSession(userData);

      _showAlert(
        message: "Login OK (${userData.roleName})",
        icon: Icons.check_circle_outline,
      );
      // ✅ manda al Splash para que él decida el destino configurado
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false,
      );
    } catch (e) {
      _showAlert(
        message: e.toString(),
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntroLogo(assetPath: AppImages.pageLoginInit, height: 200),

              if (_alertMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _alertBackgroundColor ??
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
                            color: _alertTextColor ?? theme.colorScheme.onSurface,
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
                label: appLocalizations.translate('loginManagerTitle.fieldEmail'),
                controller: emailController,
              ),

              AppSpacing.spaceBetweenInputs,

              InputTextAtom(
                label: appLocalizations.translate('loginManagerTitle.fieldPassword'),
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
                    appLocalizations.translate('loginManagerTitle.singInButton'),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterStepperPage()),
                  );
                },
                child: Text(
                  appLocalizations.translate('loginManagerTitle.register.buttonRegister'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}