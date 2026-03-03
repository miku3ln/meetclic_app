import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/auth/login_page.dart';

import '../shared/controllers/app_controller.dart';
import '../presentation/pages/splash_screen.dart';



/// ✅ Gate que NO rompe tu flujo:
/// - Default: allowGuest => SplashScreen (igual que ahora)
/// - Si activas requireLogin y no hay sesión => Login
class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    if (app.shouldShowLogin) {
      return const LoginPage();
    }

    // ✅ default
    return const SplashScreen();
  }
}