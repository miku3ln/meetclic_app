import 'package:flutter/material.dart';
import 'package:meetclic_app/data/data-sources/module_api_fake.dart';
import 'package:meetclic_app/presentation/pages/home/home_page.dart';

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

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreenAllMenu(modules: [])),
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
