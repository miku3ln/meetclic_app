import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section/filters/filters_management_main.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section/forms/forms_management.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section/controller/controllers_management.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section/models/models_management.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section/repository/repository_management.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../../shared/utils/validators/validators.dart';
import '../../../../../../shared/widgets/grids/card-rows/ps_management_row.dart';
import '../../../../../../shared/widgets/search_filter/controller/search_filter_controller.dart';
import '../../../../../../shared/widgets/search_filter/controller/search_filter_events.dart';
import '../../../../../../shared/widgets/search_filter/models/search_filter_result.dart';
import '../../../../../../shared/widgets/search_filter/search_filter_widget.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../../../widgets/loading_manager.dart';

class PosCategoriesManagementSection extends StatefulWidget {
  const PosCategoriesManagementSection({super.key});

  @override
  State<PosCategoriesManagementSection> createState() =>
      _PosCategoriesManagementSectionState();
}

class _PosCategoriesManagementSectionState
    extends State<PosCategoriesManagementSection> {
  final ScrollController _scrollController = ScrollController();
  int _simulatedTotal = 592;
  bool _isOpeningProduct = false;
  late CategoryListRepository _api;
  final List<GenericListItem<Map<String, dynamic>>> _items = [];
  int _currentPage = 1;
  final int _rowCount = 10;
  String _searchCode = '';
  int _total = 0;
  bool _isLoading = false;
  bool _hasInitialLoadFinished = false;
  bool get _hasData => _items.isNotEmpty;
  bool get _hasMore => _items.length < _total;
  final searchController = SearchFilterController();//TODO SEARCH
  StreamSubscription? _searchSub; //TODO SEARCH
  void _listenSearchEvents() {//TODO SEARCH
    _searchSub?.cancel();
    _searchSub = searchController.events.listen((event) {
      switch (event.type) {
        case SearchFilterEvents.searchChanged:
          debugPrint(event.data);
          break;
        case SearchFilterEvents.searchSubmitted:
          final result = event.data as SearchFilterResult;
          _searchCode = result.search;
          _refreshAll();
          break;
        case SearchFilterEvents.filterChanged:
          debugPrint("filterchanged");
          break;
        case SearchFilterEvents.filterApplied:
          final result = event.data as SearchFilterResult;
          debugPrint(result.toMap().toString());
          _refreshAll();
          break;
        case SearchFilterEvents.filterReset:
          _refreshAll();
          break;
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _api = CategoryListRepository(total: _simulatedTotal);
    _loadInitial();
    _scrollController.addListener(_onScroll);
    _listenSearchEvents();//TODO SEARCH

  }
  @override
  void dispose() {
    _scrollController.dispose();
    _modalActions?.cancel();

    _searchSub?.cancel();//TODO SEARCH
    searchController.dispose();//TODO SEARCH
    super.dispose();


  }
  //GRID
  Future<void> _loadInitial() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final response = await _api.fetchPage(
      current: _currentPage,
      rowCount: _rowCount,
      searchPhrase: _searchCode,
    );

    if (!mounted) return;

    setState(() {
      _items.addAll(response.rows);
      _total = response.total;
      _hasInitialLoadFinished = true;
      _isLoading = false;
    });
    _listenModalEvents(controller);
  }
//GRID
  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });
    _currentPage++;
    final response = await _api.fetchPage(
      current: _currentPage,
      rowCount: _rowCount,
      searchPhrase: _searchCode,
    );

    if (!mounted) return;

    setState(() {
      _items.addAll(response.rows);
      _total = response.total;
      _isLoading = false;
    });
  }
//GRID
  Future<void> _refreshAll() async {
    if (_isLoading) return;
    _api = CategoryListRepository(total: _simulatedTotal);

    setState(() {
      _currentPage = 1;
      _items.clear();
      _total = 0;
      _hasInitialLoadFinished = false;
    });

    await _loadInitial();
  }
//GRID
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  StreamSubscription? _modalActions;
  void _listenModalEvents(CategoryModalController controller) {
    _modalActions?.cancel();
    _modalActions = controller.eventsMainProcess.listen((event) {
      final data = event.data as Map<String, dynamic>?;
      //controller.c
      final allowReload = controller.allowReloadData;
      if (allowReload) {
        _refreshAll();
        controller.setAllowReloadData(false);
      }
      controller.resetProcess();
      switch (event.type) {
        case 'closeBtnHeader':
          break;
        case 'cancelBtnFooter':
          break;
      }
    });
  }

  void _onTapItem(GenericListItem<Map<String, dynamic>> item) async {
    if (item.data == null) return;
    setState(() {
      _isOpeningProduct = true;
    });
    try {

      await controller.init();
      final draft = ProductCategoryMapper.fromMap(item.data);
      controller.loadAndValidate(draft);
      await showManagementForm(
        context: context,
        btnSaveTitle: "Actualizar",
        btnCancelTitle: "Cancelar",
        barrierDismissible: false,
        controller: controller,
        title: "Actualizar Categoria",
        typeManagement: CrudType.update,
        managementId: draft.id!,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningProduct = false;
        });
      }
    }

  }
  final controller = CategoryModalController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: _isOpeningProduct,
          child: Column(
            children: [
              _buildHeader(),
              _buildBody(),
            ],
          ),
        ),

        // 🔥 FAB (overlay layer)
        Positioned(
          right: 32,
          bottom: 80,
          child: FloatingActionButton(
            onPressed: () async {
              setState(() {
                _isOpeningProduct = true;
              });

              try {
                await controller.init();
                if (!mounted) return;
                showManagementForm(
                  barrierDismissible: false,
                  context: context,
                  controller: controller,
                  btnSaveTitle: "Guardar",
                  btnCancelTitle: "Cancelar",
                  title: "Crear Categoria",
                  typeManagement: CrudType.create,
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isOpeningProduct = false;
                  });
                }
              }
            },
            child: const Icon(Icons.add),
          ),
        ),

        // 🔥 LOADING OVERLAY
        if (_isOpeningProduct)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );

  }
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20, // izquierda
        16, // arriba
        20, // derecha
        12, // abajo
      ),
      color: Colors.white,
      child: SearchFilterWidget(
        controller: searchController,
        config: configFilters,
      ),
    );
  }

  Widget _buildEmptyOrLoading() {
    if (!_hasInitialLoadFinished && _isLoading) {
      return const Center(child: PosLoadingView());
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 600,
          child: EmptyData(
            icon: Icons.print_rounded,
            title: 'Todavía no hay productos',
            descriptionText: 'Aquí puedes verificar',
            linkText: 'Más información',
          ),
        ),
      ],
    );
  }
  Widget _buildBody() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _refreshAll,
        child: _hasInitialLoadFinished && _hasData
            ? ListView.separated(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length + (_hasMore || _isLoading ? 1 : 0),
          separatorBuilder: (_, __) {
            final tokens = AppThemeTokens.of(context);
            return Divider(height: 1, thickness: 1, color: tokens.border);
          },
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: PosLoadingView()),
              );
            }
            final item = _items[index];
            final itemDataRow = item.data ?? {};
            return PsManagementRow(
              image: item.image,
              title: item.title,
              subtitle: item.subtitle ?? "",
              description: item.description ?? "",
              state: itemDataRow['state'] == "ACTIVE"
                  ? PsEntityState.active
                  : PsEntityState.inactive,
              chips: [
                PsInfoChip(
                  icon: Icons.category_outlined,
                  label:
                  "${itemDataRow["total_subcategories"] ?? 0} Subcategorías",
                ),
              ],

              // trailing: const Icon(Icons.chevron_right),
              onTap: () => _onTapItem(item),
            );
          },
        )
            : _buildEmptyOrLoading(),
      ),
    );
  }

}
