import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:meetclic_app/data/data-sources/module_api_fake.dart';
import 'package:meetclic_app/presentation/pages/home/home_page.dart';
import 'package:meetclic_app/presentation/pages/point_sale_page.dart';

import '../../shared/controllers/app_controller.dart';
import '../../shared/controllers/app_drawer_controller.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadResources());
  }

  Future<void> _loadResources() async {
    try {
      final app = context.read<AppController>();
      final drawer = context.read<AppDrawerController>(); // ✅ nuevo

      // ✅ Decide el target (MISMO flujo que ya tienes)
      late final Widget target;
      late final String selectedMenuId; // ✅ para marcar menú activo

      if (app.isLoggedIn) {
        switch (app.afterLoginDestination) {
          case AppAfterLoginDestination.pointSale:
            target = const PointSalePage();
            selectedMenuId = 'pos'; // ✅ debe coincidir con tu item id
            break;

          case AppAfterLoginDestination.home:
            target = HomeScreenAllMenu(modules: const []);
            selectedMenuId = 'home';
            break;
        }
      } else {
        // ✅ default: tu otro proyecto / home principal
        target = HomeScreenAllMenu(modules: const []);
        selectedMenuId = 'home';
      }

      // ✅ setear menú activo ANTES de navegar (punto 8)
      drawer.setSelected(selectedMenuId);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => target),
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