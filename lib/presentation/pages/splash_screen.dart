import 'package:flutter/material.dart';
import 'package:meetclic_app/data/data-sources/module_api_fake.dart';
import 'package:meetclic_app/infrastructure/assets/app_images.dart';
import 'package:meetclic_app/presentation/pages/home/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final ModuleApiFake api = ModuleApiFake();
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // Configura la animación
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Inicia carga de recursos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => loadResources());
  }

  Future<void> loadResources() async {
    try {
      await precacheImage(
        const AssetImage(AppImages.splashBackground),
        context,
      );
      _controller.forward(); // inicia animación

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(modules: [])),
      );
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: Image.asset(
                  AppImages.splashBackground,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              color: colorScheme.background.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
