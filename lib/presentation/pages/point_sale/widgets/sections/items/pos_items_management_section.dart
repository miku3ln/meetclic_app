import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section/pos_items_controller.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/services/media_picker_service.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../../shared/utils/validators/validators.dart';
import '../../../../../widgets/empty_data.dart';

import '../../../models/product_draft.dart';
import '../../../models/product_management_measure.dart';
import '../../../models/sections_data.dart';
import '../../../state/pos_items_controller.dart';
import '../../../state/product_modal_controller.dart';
import '../../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../molecules/inputs/ps_dropdown.dart';
import '../../molecules/inputs/ps_field_row.dart';
import '../../molecules/inputs/ps_input.dart';
import '../../molecules/ps_image_picker.dart';
import '../../organisms/dialogs/product_modal.dart';
import '../../organisms/items/pos_items_content.dart';
import '../../organisms/ps_toogle_group.dart';
import '../product/ps_section_card.dart';

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
  @override
  void initState() {
    super.initState();
    _api = PosItemsManagementApi(total: _simulatedTotal);
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final response = await _api.fetchPage(
      current: _currentPage,
      rowCount: _rowCount,
      searchPhrase: _searchCode
    );

    if (!mounted) return;

    setState(() {
      _items.addAll(response.rows);
      _total = response.total;
      _hasInitialLoadFinished = true;
      _isLoading = false;
    });
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

  Future<void> _onTapItem(
      GenericListItem<Map<String, dynamic>> item,
      ) async {
    if (item.data == null) return;

    setState(() {
      _isOpeningProduct = true;
    });

    try {
      final controller = ProductModalController();

      await controller.init();

      final draft = ProductMapper.fromMap(item.data!);

      controller.loadAndValidate(draft);

      final catalogMeasureData =
      await PosMockData.getCatalogMeasureData();

      final catalogTaxData =
      await PosMockData.getCatalogTaxData();

      if (!mounted) return;

      await showManagerProduct(
        context: context,
        btnSaveTitle: "Actualizar",
        btnCancelTitle: "Cancelar",
        barrierDismissible: false,
        controller: controller,
        title: "Actualizar Producto",
        type: CrudType.update,
        listMeasureCategory: catalogMeasureData,
        listTaxCategory: catalogTaxData,
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
          child: Stack(
            children: [
              if (!_hasInitialLoadFinished && _isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
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
                      final controller = ProductModalController();

                      await controller.init();

                      final catalogMeasureData =
                      await PosMockData.getCatalogMeasureData();

                      final catalogTaxData =
                      await PosMockData.getCatalogTaxData();

                      if (!mounted) return;

                      await showManagerProduct(
                        barrierDismissible: false,
                        context: context,
                        controller: controller,
                        btnSaveTitle: "Guardar",
                        btnCancelTitle: "Cancelar",
                        title: "Crear Producto",
                        type: CrudType.create,
                        listMeasureCategory: catalogMeasureData,
                        listTaxCategory: catalogTaxData,
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
              child: const Center(
                child: CircularProgressIndicator(),
              ),
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
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = _items[index];

          return ProductListCard(
            item: item,
            onTap: () => _onTapItem(item),
          );
        },
      ),
    );
  }
}

enum ProductViewMode { dialog, page }

Future<void> showManagerProduct({
  required BuildContext context,
  required ProductModalController controller,
  required String title,
  required String btnCancelTitle,
  required String btnSaveTitle,
  required List<MeasureCategoryModel> listMeasureCategory,
  required List<TaxCategoryModel> listTaxCategory,
  CrudType type = CrudType.update,
  required bool barrierDismissible,
  ProductViewMode viewMode = ProductViewMode.page,
}) async {
  final allowModal = viewMode == ProductViewMode.dialog;
  final content = AnimatedBuilder(
    animation: controller,
    builder: (_, __) {
      return PsModalLayout(
        useDialog: allowModal,
        title: title,
        btnCancelTitle: btnCancelTitle,
        btnSaveTitle: btnSaveTitle,
        onSave: controller.canSubmit
            ? () {
                if (controller.validate().success) {
                  controller.save(type);
                  Navigator.pop(context);
                }
              }
            : null,
        body: _buildProductBody(
          context,
          controller,
          type,
          title,
          listMeasureCategory,
          listTaxCategory,
        ),
      );
    },
  );

  if (viewMode == ProductViewMode.dialog) {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => content,
    );
    return;
  }

  await Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return content;
      },
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
    ),
  );
}
Widget _buildProductBody(
    BuildContext context,
    ProductModalController controller,
    CrudType type,
    String title,
    List<MeasureCategoryModel> listMeasureCategory,
    List<TaxCategoryModel> listTaxCategory,
    ) {
  final recipeEnabled =
      controller.inventoryType == InventoryType.processed ||
          controller.inventoryType == InventoryType.forSale;

  return ProductTabsView(
    controller: controller,
    listMeasureCategory: listMeasureCategory,
    listTaxCategory: listTaxCategory,
  );
}
Widget _buildTabProduct(
    BuildContext context,
    ProductModalController controller,
    List<MeasureCategoryModel> listMeasureCategory,
    List<TaxCategoryModel> listTaxCategory,
    ) {
  return SingleChildScrollView(
    child: Column(
      children: [
        /// =========================
        /// 📦 INFORMACIÓN
        /// =========================
        PsSectionSplit(
          leftFlex: 7,
          rightFlex: 3,
          left: PsSectionCard(
            title: "Información General",
            child: Column(
              children: [
                PsFieldRow(
                  children: [
                    PsFieldItem(
                      child: PsToggleSelector<InventoryType>(
                        title: "Tipo de  Producto",
                        value: controller.inventoryType,
                        items: InventoryType.values,
                        onChanged: controller.setInventoryType,
                      ),
                    ),
                    PsFieldItem(
                      child: PsInput(
                        requiredField: true,
                        label: "Codigo",
                        value: controller.codeBar,
                        keyboardType: TextInputType.text,
                        onChanged: controller.setCodeBar,
                        error: controller.codeBarError,
                        isTouched: controller.codeBarTouched,
                        isValid: controller.codeBarError == null,
                      ),
                    ),
                    PsFieldItem(
                      child: PsInput(
                        requiredField: true,
                        label: "REF",
                        value: controller.ref,
                        keyboardType: TextInputType.text,
                        onChanged: controller.setRef,
                        error: controller.refError,
                        isTouched: controller.refTouched,
                        isValid: controller.refError == null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.spaceBetweenInputs,

                PsFieldRow(
                  children: [
                    PsFieldItem(
                      flex: 2,
                      child: PsInput(
                        label: "Nombre",
                        requiredField: true,
                        value: controller.name,
                        onChanged: controller.setName,
                        error: controller.nameError,
                        isTouched: controller.nameTouched,
                        isValid:
                        controller.nameError == null &&
                            controller.name.isNotEmpty,
                      ),
                    ),

                    PsFieldItem(
                      flex: 2,
                      child: Center(
                        child: PsImagePicker(
                          image: controller.image,
                          error: controller.imageError,
                          onPick: () async {
                            final mediaService = MediaPickerService();
                            final file = await showImageSourceSelector(
                              context,
                              mediaService.pickFromCamera,
                              mediaService.pickFromGallery,
                            );

                            if (file != null) {
                              controller.setImage(file);
                            }
                          },
                          onRemove: controller.removeImage,
                          requiredField: true,
                          isTouched: controller.imageTouched,
                          isValid: controller.image != null,
                        ),
                      ),
                    ),

                    /// 🔥 NOMBRE
                  ],
                ),
                AppSpacing.spaceBetweenInputs,
                PsFieldRow(
                  children: [
                    /// 🔥 CATEGORÍA
                    PsFieldItem(
                      child: PsDropdown(
                        label: "Categoría",
                        items: controller.categories,
                        value: controller.selectedCategory,
                        getLabel: (e) => e.value,
                        onChanged: controller.selectCategory,
                        error: controller.categoryError,
                        requiredField: true,
                        isTouched: controller.categoryTouched,
                        isValid: controller.selectedCategory != null,
                      ),
                    ),
                    PsFieldItem(
                      child:
                      /// 🔥 SUBCATEGORÍA
                      PsDropdown(
                        label: "Subcategoría",
                        items: controller.subcategories,
                        value: controller.selectedSubcategory,
                        getLabel: (e) => e.value,
                        onChanged: controller.selectSubcategory,
                        error: controller.subcategoryError,
                        requiredField: true,
                        isTouched: controller.subcategoryTouched,
                        isValid: controller.selectedSubcategory != null,
                      ),
                    ),
                  ],
                ),

                AppSpacing.spaceBetweenInputs,
              ],
            ),
          ),
          right: PsSectionCard(
            title: "Costos y Precios",
            child: Column(
              children: [
                /// 🔥 PRECIO + COSTE
                PsFieldRow(
                  children: [
                    PsFieldItem(
                      flex: 1,
                      child: PsDropdown<TaxCategoryModel>(
                        label: "Impuesto",
                        items: listTaxCategory,
                        value: controller.selectedTax,
                        getLabel: (e) => '${e.name} (${e.description})',
                        onChanged: controller.selectTax,
                        error: controller.taxCategoryError,
                        requiredField: true,
                        isTouched: controller.taxTouched,
                        isValid: controller.selectedTax != null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.spaceBetweenInputs,

                PsFieldRow(
                  children: [
                    PsFieldItem(
                      child: PsInput(
                        value: controller.price.toString(),
                        requiredField: true,
                        label: "Precio",
                        keyboardType: TextInputType.number,
                        onChanged: controller.setPrice,
                        error: controller.priceError,
                        isTouched: controller.priceTouched,
                        isValid: controller.priceError == null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.spaceBetweenInputs,

                PsFieldRow(
                  children: [
                    PsFieldItem(
                      child: PsInput(
                        requiredField: true,
                        value: controller.cost.toString(),
                        label: "Coste",
                        keyboardType: TextInputType.number,
                        onChanged: controller.setCost,
                        error: controller.costError,
                        isTouched: controller.costTouched,
                        isValid: controller.costError == null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AppSpacing.spaceBetweenSections,

        PsSectionCard(
          title: "Inventario Inicial",
          child: Column(
            children: [
              PsFieldRow(
                children: [
                  PsFieldItem(
                    child: PsToggleSelector<MeasureType>(
                      title: "Tipo de Medida",
                      value: controller.sellType,
                      items: MeasureType.values,
                      onChanged: controller.setMeasureType,
                    ),
                  ),
                  PsFieldItem(
                    child: _buildMeasureWidget(
                      controller.sellType,
                      listMeasureCategory,
                      controller,
                    ),
                  ),
                ],
              ),

              PsFieldRow(
                children: [
                  PsFieldItem(
                    child: PsInput(
                      requiredField: true,
                      value: controller.stock.toString(),
                      label: "Stock",
                      keyboardType: TextInputType.number,
                      onChanged: controller.setStock,
                      isTouched: controller.stockTouched,
                      error: controller.stockError,
                      isValid: controller.stockError == null,
                    ),
                  ),
                  PsFieldItem(
                    child: PsInput(
                      value: controller.lowStock.toString(),
                      requiredField: true,
                      label: "Stock mínimo",
                      keyboardType: TextInputType.number,
                      onChanged: controller.setLowStock,
                      error: controller.lowStockError,
                      isTouched: controller.lowStockTouched,
                      isValid: controller.lowStockError == null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.spaceBetweenSections,
        /// =========================
        /// 📦 INVENTARIO
        /// =========================
      ],
    ),
  );
}
Widget _buildTabRecipe(
    BuildContext context,
    ProductModalController controller,
    List<MeasureCategoryModel> listMeasureCategory,
    ) {
  final recipeEnabled =
      controller.inventoryType == InventoryType.processed ||
          controller.inventoryType == InventoryType.forSale;
  return SingleChildScrollView(
    child: PsSectionCard(
      title: switch (controller.inventoryType) {
        InventoryType.raw => 'Receta',
        InventoryType.processed => 'Receta - Materias Primas',
        InventoryType.forSale => 'Receta - Productos Procesados',
      },

      child: Column(
        children: [

          recipeEnabled?PsSectionCard(
            title: switch (controller.inventoryType) {
              InventoryType.raw => 'Receta ',
              InventoryType.processed => 'Receta',
              InventoryType.forSale => 'Receta',
            },
            child: Column(
              children: [
                PsFieldRow(
                  children: [
                    /// 🔥 CATEGORÍA
                    PsFieldItem(
                      child: PsDropdown(
                        label: switch (controller.inventoryType) {
                          InventoryType.raw =>
                          'Receta - Ingrese Productos Materia Prima',
                          InventoryType.processed => 'Materia Prima',
                          InventoryType.forSale => ' Productos procesados',
                        },
                        items: controller.categories,
                        value: controller.selectedCategory,
                        getLabel: (e) => e.value,
                        onChanged: controller.selectCategory,
                        error: controller.categoryError,
                        requiredField: true,
                        isTouched: controller.categoryTouched,
                        isValid: controller.selectedCategory != null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.spaceBetweenSections,

                PsFieldRow(
                  children: [
                    PsFieldItem(
                      child: PsToggleSelector<MeasureType>(
                        title: "Total de Tipos de Productos Agregados",
                        value: controller.sellType,
                        items: MeasureType.values,
                        onChanged: controller.setMeasureType,
                      ),
                    ),
                    PsFieldItem(
                      child: _buildMeasureWidget(
                        controller.sellType,
                        listMeasureCategory,
                        controller,
                      ),
                    ),
                  ],
                ),
                AppSpacing.spaceBetweenSections,
                SizedBox(
                  height: 400, // ajusta a tu necesidad
                  child: ListView.separated(
                    itemCount: controller.ingredients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final e = controller.ingredients[index];
                      return PsIngredientCard(
                        item: e,
                        measureCategories: listMeasureCategory,
                        onQuantityChanged: (value) {
                          controller.updateIngredientQuantity(e, value);
                        },
                        onUnitChanged: (unit) {
                          controller.updateIngredientUnit(e, unit);
                        },
                        onEdit: () {},
                        onDelete: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ):SizedBox.shrink()

        ],
      ),
    ),
  );
}
Widget _buildMeasureWidget(
  MeasureType type,
  List<MeasureCategoryModel> listMeasureCategory,
  ProductModalController controller,
) {
  if (type == MeasureType.unit) {
    return const SizedBox.shrink();
  }

  final resultSet = listMeasureCategory.firstWhere(
    (e) => e.id.toString() == type.id,
  );

  final unitsWithConversions = resultSet.units
      .where((unit) => unit.conversions.isNotEmpty)
      .toList();

  return PsDropdown<UnitMeasureModel>(
    label: "Medida",
    items: unitsWithConversions,
    value: controller.selectedUnitMeasure,
    getLabel: (e) => '${e.name} (${e.symbol})',
    onChanged: controller.selectUnitsByMeasure,
    error: controller.measureCategoryError,
    requiredField: true,
    isTouched: controller.measureCategoryTouched,
    isValid: controller.selectedUnitMeasure != null,
  );
}

class PsIngredientCard extends StatelessWidget {
  final RecipeIngredientItem item;

  final List<MeasureCategoryModel> measureCategories;

  final ValueChanged<String> onQuantityChanged;

  final ValueChanged<UnitMeasureModel?> onUnitChanged;

  final VoidCallback onEdit;

  final VoidCallback onDelete;

  const PsIngredientCard({
    super.key,
    required this.item,
    required this.measureCategories,
    required this.onQuantityChanged,
    required this.onUnitChanged,
    required this.onEdit,
    required this.onDelete,
  });

  List<UnitMeasureModel> getUnits() {
    final category = measureCategories.firstWhere(
      (e) => e.id.toString() == item.measureType.id,
    );

    return category.units;
  }

  @override
  Widget build(BuildContext context) {
    return PsSectionCard(
      title: item.name,
      child: Column(
        children: [
          /// FILA 1
          PsSectionSplit(
            left: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  Text(item.measureType.value),
                  PsBadge(label: item.measureType.value),
                ],
              ),
            ),

            right: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),

          AppSpacing.spaceBetweenInputs,
          PsFieldRow(
            children: [
              PsFieldItem(
                flex: 2,
                child: PsInput(
                  label: 'Cantidad',
                  value: item.quantity.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: onQuantityChanged,
                ),
              ),
              PsFieldItem(
                flex: 2,
                child: PsDropdown<UnitMeasureModel>(
                  label: item.measureType.value,
                  items: getUnits(),
                  value: item.selectedUnit,
                  getLabel: (e) => '${e.name} (${e.symbol})',
                  onChanged: onUnitChanged,
                ),
              ),
              PsFieldItem(
                flex: 2,
                child: _buildBaseInfo(item, measureCategories),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PsBadge extends StatelessWidget {
  final String label;

  const PsBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.primary.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primary.withOpacity(.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySecondary(
          context,
        ).copyWith(color: c.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

Widget _buildBaseInfo(
  RecipeIngredientItem item,
  List<MeasureCategoryModel> measureCategories,
) {
  if (item.selectedUnit == null) {
    return const SizedBox.shrink();
  }

  final category = measureCategories.firstWhere(
    (e) => e.id.toString() == item.measureType.id,
  );

  final baseValue = item.quantity * item.selectedUnit!.factorToBase;

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Equiv. Base'),
        const SizedBox(height: 8),

        Text(
          '${baseValue.toStringAsFixed(2)} ${category.baseUnit.symbol}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
class ProductTabsView extends StatefulWidget {
  final ProductModalController controller;
  final List<MeasureCategoryModel> listMeasureCategory;
  final List<TaxCategoryModel> listTaxCategory;

  const ProductTabsView({
    super.key,
    required this.controller,
    required this.listMeasureCategory,
    required this.listTaxCategory,
  });

  @override
  State<ProductTabsView> createState() => _ProductTabsViewState();
}

class _ProductTabsViewState extends State<ProductTabsView>
    with SingleTickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeEnabled =
        widget.controller.inventoryType == InventoryType.processed ||
            widget.controller.inventoryType == InventoryType.forSale;

    return Column(
      children: [

        TabBar(
          controller: tabController,
          tabs: [
            const Tab(
              text: 'Producto',
              icon: Icon(Icons.inventory_2_outlined),
            ),
            Tab(
              text: recipeEnabled ? 'Receta' : '',
              icon: Icon(
                recipeEnabled
                    ? Icons.restaurant_menu
                    : Icons.lock_outline,
              ),
            ),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _buildTabProduct(
                context,
                widget.controller,
                widget.listMeasureCategory,
                widget.listTaxCategory,
              ),

              recipeEnabled
                  ? _buildTabRecipe(
                context,
                widget.controller,
                widget.listMeasureCategory,
              )
                  : const Center(
                child: Text(
                  'Disponible únicamente para productos procesados',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


