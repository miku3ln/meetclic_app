import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetclic_app/domain/entities/menu_tab_up_item.dart';
import 'package:meetclic_app/shared/themes/app_colors.dart';

import '../pages/dictionary_page/categories_top.dart';
import '../pages/dictionary_page/controllers/dictionary_controller.dart';
import '../pages/dictionary_page/repositories/dictionary_repository.dart';
import '../pages/dictionary_page/search_language_app_bar.dart';
import '../pages/dictionary_page/services/mock_dictionary_service.dart';
import '../pages/dictionary_page/word_tile.dart';

class DictionaryPage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;
  final String Function(MenuTabUpItem item)? labelBuilder;

  const DictionaryPage({
    super.key,
    required this.title,
    required this.itemsStatus,
    this.labelBuilder,
  });

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  late final DictionaryController _vm;
  late final CategoryController _controllerCategory;
  @override
  void initState() {
    super.initState();
    _vm = DictionaryController(DictionaryRepository(MockDictionaryService()))
      ..addListener(() => setState(() {}));

    _vm.attachScrollHandlers(_scrollController);
    scheduleMicrotask(_vm.loadInitial); // carga inicial
    _controllerCategory = CategoryController(
      items: grammaticalClassCatalog,
      initialSelectedId: GrammaticalClass.sustantivo,
    );
  }

  @override
  void dispose() {
    _vm.dispose();
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _safeLabel(MenuTabUpItem item) => item.name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool viewCategoriesTop = false;
    // Bouncing + AlwaysScrollable permite overscroll también en Android
    final ScrollPhysics basePhysics = _vm.scrollLocked
        ? const NeverScrollableScrollPhysics()
        : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SearchLanguageAppBar(
        controller: _searchCtrl,
        onChanged: _vm.onSearchChanged,
        onFilterTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => SizedBox(
              height: 240,
              child: Center(
                child: Text(
                  'Aquí tus filtros (lang: ${_vm.language}, q: ${_vm.query})',
                ),
              ),
            ),
          );
        },
        language: _vm.language,
        onLanguageChanged: _vm.setLanguage,
      ),
      body: SafeArea(
        child: _vm.isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : AbsorbPointer(
                absorbing: _vm.scrollLocked,
                child: RefreshIndicator(
                  onRefresh: _vm.reload,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: basePhysics,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (viewCategoriesTop)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CategoryCarousel(
                              controller: _controllerCategory,
                              showNumberBadge: true,
                              onChanged: (id) {
                                // Aquí filtras tu lista o lanzas queries por clase gramatical
                                debugPrint('Seleccionado id = $id');
                                _vm.selectedCategory = id;
                                _vm.setCategory(id);
                              },
                              // Ejemplo de leading con IconData si no quieres assets:
                              leadingBuilder: (item, selected) {
                                return Icon(
                                  Icons.bookmark_outline,
                                  size: 16,
                                  color: selected
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFF607D8B),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                        // -------------------- HEADER LISTA --------------------
                        Row(
                          children: [
                            Text(
                              'New Words',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.grisOscuro,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // -------------------- LISTA DE TARJETAS --------------------
                        ListView.separated(
                          itemCount: _vm.items.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final w = _vm.items[index];
                            return WordTile(
                              item: w,
                              onPlay: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reproducir: ${w.title}'),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        if (_vm.isLoadingMore) ...[
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                        ],
                        if (!_vm.hasMore && _vm.items.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'No more results',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
