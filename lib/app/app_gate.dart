import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/auth/login_page.dart';

import '../presentation/widgets/loading_manager.dart';
import '../shared/controllers/app_controller.dart';
import '../presentation/pages/splash_screen.dart';

import '../domain/services/session_service.dart';

/// ✅ Gate que NO rompe tu flujo:
/// - Default: allowGuest => SplashScreen (igual que ahora)
/// - Si activas requireLogin y no hay sesión => Login
class AppGate extends StatelessWidget {
  const AppGate({super.key});
  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionService>();
    final app = context.watch<AppController>();

    // ✅ Asegura carga de sesión persistida antes de decidir
    if (!session.hydrated) {
      session.ensureLoaded(); // una sola vez realmente, por hydrated
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: PosLoadingView()),
      );
    }
    // 🔒 si exige login y no hay sesión => Login
    if (app.shouldShowLogin) {
      return const LoginPage();
    }

    // ✅ default => Splash (igual que ahora)
    return const SplashScreen();
  }
}