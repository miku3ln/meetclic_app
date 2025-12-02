import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/widgets/home/carousel_section.dart';
import 'package:meetclic_app/presentation/widgets/home/news_item.dart';
import 'package:meetclic_app/presentation/widgets/home/promo_banner.dart';

import '../../../presentation/widgets/gamified-task-card/organisms/gamified_task_card.dart';

class HomeScrollView extends StatefulWidget {
  const HomeScrollView({super.key});

  @override
  State<HomeScrollView> createState() => _HomeScrollViewState();
}

class _HomeScrollViewState extends State<HomeScrollView> {
  final ScrollController _scrollController = ScrollController();
  final List<Widget> _widgets = [];
  bool _isLoading = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureEnoughContent();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading) {
      _loadMoreContent();
    }
  }

  Future<void> _ensureEnoughContent() async {
    do {
      await _loadMoreContent();
      await Future.delayed(const Duration(milliseconds: 300));
    } while (_scrollController.position.maxScrollExtent <
            MediaQuery.of(context).size.height &&
        !_isLoading);
  }

  Future<void> _loadMoreContent() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final data = _fetchFakeApi(_page++);
    final newWidgets = data.map(_buildWidgetFromData).toList();

    setState(() {
      _widgets.addAll(newWidgets);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _fetchFakeApi(int page) {
    final List<String> types = ['news', 'carousel', 'promo', 'card'];
    final random = Random();
    final int count = random.nextInt(4) + 5; // entre 5 y 8 elementos

    return List.generate(count, (index) {
      final type = types[random.nextInt(types.length)];
      return {
        'type': type,
        'title': '$type block #${(page - 1) * 10 + index + 1}',
        'data': {'content': 'Contenido simulado de tipo $type'},
      };
    });
  }

  Widget _buildWidgetFromData(Map<String, dynamic> block) {
    switch (block['type']) {
      case 'news':
        return NewsItem(title: block['title']);
      case 'carousel':
        return const CarouselSection();
      case 'promo':
        return PromoBanner(text: block['title']);

      case 'card':
        return GamifiedTaskCard(
          title: 'Códigos de Descuento',
          subtitle: 'Gana mientras ayudas',
          description:
              'Comparte este producto con 3 personas y gana 25 Yapitas que puedes canjear.',
          badge: '+25 Yapitas',
          icon: Icons.share,
          imageUrl:
              'https://assets.adidas.com/images/w_1880,f_auto,q_auto/dc9953df47e443a79524adc50177d71e_9366/GY5427_01_standard.jpg',
          sponsor: 'MeetClic',
          endDate: '13-08-2025',
          buttonText: 'Comenzar',
          buttonColor: Colors.amber,
          onPressed: () {
            // Acción al hacer clic (navegación, diálogo, etc.)
            print('Tarea iniciada');
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _widgets.clear();
      _page = 1;
    });
    await _ensureEnoughContent();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      color: Colors.yellow,
      // Color del círculo (barra giratoria)
      backgroundColor: theme.colorScheme.onSurface,
      // Color del círculo interior (de fondo)
      displacement: 50,
      // Distancia desde la parte superior (opcional)
      strokeWidth: 3.5,
      // Grosor del círculo (opcional)
      onRefresh: _onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  ..._widgets,
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber,
                          ),
                          backgroundColor: Colors.white,
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
