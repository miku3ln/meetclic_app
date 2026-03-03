import 'package:flutter/material.dart';
import 'package:meetclic_app/data/data-sources/module_api_fake.dart';
import 'package:meetclic_app/presentation/pages/home/home_page.dart';
import 'package:meetclic_app/presentation/pages/point_sale_page.dart';
import 'package:meetclic_app/shared/providers_session.dart';

import '../../shared/controllers/app_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ModuleApiFake api = ModuleApiFake();

  @override
  void initState() {
    super.initState();
    // Inicia la carga después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadResources());
  }

  Future<void> _loadResources() async {
    try {
      // Aquí podrías cargar cosas reales, por ahora nada:
      // await api.loadModules();

      // (Opcional) pequeña pausa para que se vea el loading
      // await Future.delayed(const Duration(milliseconds: 500));
      final app = context.read<AppController>();

      Widget target;
      // ✅ si está logueado, respeta tu configuración post-login
      if (app.isLoggedIn) {
        switch (app.afterLoginDestination) {
          case AppAfterLoginDestination.pointSale:
            target = PointSalePage();
            break;
          case AppAfterLoginDestination.home:
            target = HomeScreenAllMenu(modules: []);
            break;
        }
      } else {
        // ✅ si NO está logueado, sigue tu flujo normal
        target = HomeScreenAllMenu(modules: []);
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) =>target),
      );
    } catch (e, st) {
      debugPrint('Error cargando datos: $e');
      debugPrint('$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
