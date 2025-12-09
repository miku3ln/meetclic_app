import 'package:flutter/material.dart';

import '../../domain/entities/menu_tab_up_item.dart';
import '../widgets/template/custom_app_bar.dart';
import 'more_page/services/more_mapper_service.dart';
import 'more_page/state/more_state.dart';
import 'more_page/widgets/organisms/more_sections_list_organism.dart';

class MorePage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const MorePage({super.key, required this.title, required this.itemsStatus});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  late final MoreState _state;
  final _mapper = const MoreMapperService();
  final ScrollController _scrollController = ScrollController();
  double _previousOffset = 0;

  void _loadSections() {
    final sections = _mapper.buildSections(context);
    print('📌 Sections generadas: ${sections.length}');

    setState(() {
      _state = MoreState(sections: sections);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSections();
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
        child: MoreSectionsListOrganism(
          sections: _state.sections,
          scrollController: _scrollController,
          bottomExtraSpace:
              screenHeight * 0.10, // el “espacio de prueba” que tenías
        ),
      ),
    );
  }
}
