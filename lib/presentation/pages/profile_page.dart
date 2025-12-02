import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/presentation/pages/profile-page/organisms/user-profile-header.dart';

import '../../../presentation/widgets/template/custom_app_bar.dart';

class ProfilePage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const ProfilePage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  double _previousOffset = 0;

  @override
  void initState() {
    super.initState();

    // Escuchar todos los eventos del scroll
    _scrollController.addListener(() {
      final position = _scrollController.position;

      // 1. Scroll en progreso
      print('🔄 Posición actual: ${position.pixels}');

      // 2. Llegar al final
      if (position.pixels >= position.maxScrollExtent) {
        print('✅ Llegaste al final (infinite scroll)');
      }

      // 3. Llegar al inicio
      if (position.pixels <= position.minScrollExtent) {
        print('⬆️ Estás en el inicio del scroll');
      }

      // 4. Dirección del scroll
      if (position.pixels > _previousOffset) {
        print('⬇️ Bajando');
      } else if (position.pixels < _previousOffset) {
        print('⬆️ Subiendo');
      }
      _previousOffset = position.pixels;

      // 5. Overscroll (rebote fuera de límites)
      if (position.outOfRange) {
        print('⚠️ Overscroll detectado');
      }

      // 6. Porcentaje del scroll
      final double scrollPercent = (position.pixels / position.maxScrollExtent)
          .clamp(0.0, 1.0);
      print('📊 Scroll: ${(scrollPercent * 100).toStringAsFixed(1)}%');
    });

    // 7. Inicio / fin de arrastre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.position.isScrollingNotifier.addListener(() {
        final isScrolling =
            _scrollController.position.isScrollingNotifier.value;
        if (isScrolling) {
          print('👆 Usuario está arrastrando el scroll');
        } else {
          print('🛑 Usuario dejó de arrastrar');
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ✅ Buenas prácticas
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          controller: _scrollController, // ✅ Asignamos el controller
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfileHeader(),
              SizedBox(
                height: screenHeight * 0.10,
              ), // Solo para permitir scroll de prueba
            ],
          ),
        ),
      ),
    );
  }
}
