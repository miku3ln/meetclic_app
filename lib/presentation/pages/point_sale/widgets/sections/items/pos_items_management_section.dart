import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section_utils/form_management/form_management.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section_utils/pos_items_controller.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/utils/validators/validators.dart';
import '../../../../../../shared/widgets/search_filter/controller/search_filter_controller.dart';
import '../../../../../../shared/widgets/search_filter/controller/search_filter_events.dart';
import '../../../../../../shared/widgets/search_filter/models/filter_field.dart';
import '../../../../../../shared/widgets/search_filter/models/filter_item.dart';
import '../../../../../../shared/widgets/search_filter/models/search_filter_config.dart';
import '../../../../../../shared/widgets/search_filter/models/search_filter_result.dart';
import '../../../../../../shared/widgets/search_filter/search_filter_widget.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../../../widgets/loading_manager.dart';
import '../../../models/product_draft.dart';
import '../../../state/product_modal_controller.dart';
import '../../organisms/items/pos_items_content.dart';

class ProductModalEvents {
  static const save = 'save';
  static const create = 'create';
  static const update = 'update';
  static const recipeAdd = 'recipe_add';
  static const recipeDelete = 'recipe_delete';
  static const recipeUpdate = 'recipe_update';
  static const close = 'close';
  static const cancel = 'cancel';
}

class PosItemsManagementSection extends StatefulWidget {
  const PosItemsManagementSection({super.key});

  @override
  State<PosItemsManagementSection> createState() =>
      _PosItemsManagementSectionState();
}

class _PosItemsManagementSectionState extends State<PosItemsManagementSection> {
  final ScrollController _scrollController = ScrollController();
  bool _isOpeningProduct = false;
  final TextEditingController _searchController = TextEditingController();
  late PosItemsManagementApi _api;
  final List<GenericListItem<Map<String, dynamic>>> _items = [];
  int _currentPage = 1;
  final int _rowCount = 10;
  int _total = 0;
  bool _isLoading = false;
  bool _hasInitialLoadFinished = false;
  String _searchCode = '';
  bool get _hasData => _items.isNotEmpty;
  bool get _hasMore => _items.length < _total;

  /// aquí decides el total simulado
  int _simulatedTotal = 592;
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
          debugPrint(event.data);
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
    _api = PosItemsManagementApi(total: _simulatedTotal);
    _loadInitial();
    _scrollController.addListener(_onScroll);
    _listenSearchEvents();//TODO SEARCH
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _modalSub?.cancel();
    _modalActions?.cancel();

    _searchSub?.cancel();//TODO SEARCH
    searchController.dispose();//TODO SEARCH
    super.dispose();
  }
  final config = SearchFilterConfig(
    hint: "Buscar artículos",
    drawerTitle: "Filtros",
    fields: [
      FilterField(
        id: "status",
        label: "Estado",

        type: FilterFieldType.dropdown,

        items: [

          FilterItem(
            id: "1",
            label: "Activo",
            value: "ACTIVE",
          ),

          FilterItem(
            id: "2",
            label: "Inactivo",
            value: "INACTIVE",
          ),

        ],

      ),

      FilterField(

        id: "category",

        label: "Categoría",

        type: FilterFieldType.dropdown,

        items: [

          FilterItem(
            id: "1",
            label: "Menú",
            value: 1,
          ),

          FilterItem(
            id: "2",
            label: "Materia Prima",
            value: 2,
          ),

        ],

      ),

    ],

  );
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

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });
    _currentPage++;
    final response = await _api.fetchPage(
      current: _currentPage,
      searchPhrase: _searchCode,
      rowCount: _rowCount,
    );

    if (!mounted) return;

    setState(() {
      _items.addAll(response.rows);
      _total = response.total;
      _isLoading = false;
    });
  }

  Future<void> _refreshAll() async {
    if (_isLoading) return;
    _api = PosItemsManagementApi(total: _simulatedTotal);

    setState(() {
      _currentPage = 1;
      _items.clear();
      _total = 0;
      _hasInitialLoadFinished = false;
    });

    await _loadInitial();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  StreamSubscription? _modalSub;
  StreamSubscription? _modalActions;

  void _listenModalEvents(ProductModalController controller) {
    _modalSub?.cancel();
    _modalActions?.cancel();
    _modalSub = controller.events.listen((event) {
      final data = event.data as Map<String, dynamic>?;
      switch (event.type) {
        case ProductModalEvents.save:
          final allowReload = data?['allowReload'] ?? false;
          if (allowReload) {
            controller.setAllowReloadData(false);
            _refreshAll();
          }
          break;
        case ProductModalEvents.create:
          _refreshAll();
          break;
        case ProductModalEvents.update:
          _refreshAll();
          break;
        case ProductModalEvents.recipeAdd:
          debugPrint('recipe add: ${event.data}');
          break;
        case ProductModalEvents.recipeDelete:
          debugPrint('recipe delete: ${event.data}');
          break;
        case ProductModalEvents.close:
          debugPrint('modal closed');
          break;
        case ProductModalEvents.cancel:
          debugPrint('cancelled');
          break;
      }
    });
    _modalActions = controller.eventsModalProduct.listen((event) {
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

  Future<void> _onTapItem(GenericListItem<Map<String, dynamic>> item) async {
    if (item.data == null) return;

    setState(() {
      _isOpeningProduct = true;
    });

    try {
      controller.resetAllForm();
      await controller.init();
      final draft = ProductMapper.fromMap(item.data!);
      controller.loadAndValidate(draft);
      if (!mounted) return;
      await showManagerProduct(
        context: context,
        btnSaveTitle: "Actualizar",
        btnCancelTitle: "Cancelar",
        barrierDismissible: false,
        controller: controller,
        title: "Actualizar Producto",
        typeManagement: CrudType.update,
        listMeasureCategory: controller.listMeasureCategoryManagement,
        listTaxCategory: controller.listTaxCategoryManagement,
        productId: draft.id!,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningProduct = false;
        });
      }
    }
  }

  final controller = ProductModalController();
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
                controller.resetAllForm();
                await controller.init();

                if (!mounted) return;

                await showManagerProduct(
                  barrierDismissible: false,
                  context: context,
                  controller: controller,
                  btnSaveTitle: "Guardar",
                  btnCancelTitle: "Cancelar",
                  title: "Crear Producto",
                  typeManagement: CrudType.create,
                  listMeasureCategory:
                  controller.listMeasureCategoryManagement,
                  listTaxCategory: controller.listTaxCategoryManagement,
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

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_hasMore || _isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.zero,
              child: Center(child: PosLoadingView()),
            );
          }
          final item = _items[index];
          return ProductListCard(item: item, onTap: () => _onTapItem(item));
        },
      ),
    );
  }
  Widget build2(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: _isOpeningProduct,
          child: Stack(
            children: [
              if (!_hasInitialLoadFinished && _isLoading)
                const Center(child: PosLoadingView())
              else if (!_hasData)
                RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: ListView(
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
                  ),
                )
              else
                _buildList(),
              Positioned(
                right: 32,
                bottom: 80,
                child: FloatingActionButton(
                  onPressed: () async {
                    setState(() {
                      _isOpeningProduct = true;
                    });

                    try {
                      controller.resetAllForm();
                      await controller.init();
                      if (!mounted) return;
                      await showManagerProduct(
                        barrierDismissible: false,
                        context: context,
                        controller: controller,
                        btnSaveTitle: "Guardar",
                        btnCancelTitle: "Cancelar",
                        title: "Crear Producto",
                        typeManagement: CrudType.create,
                        listMeasureCategory:
                        controller.listMeasureCategoryManagement,
                        listTaxCategory: controller.listTaxCategoryManagement,
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
            ],
          ),
        ),

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
      color: Colors.white,
      child: SearchFilterWidget(
        controller: searchController,
        config: config,
      ),
    );
  }
  Widget _buildBody() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _refreshAll,
        child: _hasInitialLoadFinished && _hasData
            ? ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length + (_hasMore || _isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const Center(child: PosLoadingView());
            }

            final item = _items[index];
            return ProductListCard(
              item: item,
              onTap: () => _onTapItem(item),
            );
          },
        )
            : _buildEmptyOrLoading(),
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
}
