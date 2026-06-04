import 'package:flutter/material.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/services/media_picker_service.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
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

  /// aquí decides el total simulado
  int _simulatedTotal = 592;

  late PosItemsManagementApi _api;

  final List<GenericListItem<Map<String, dynamic>>> _items = [];

  int _currentPage = 1;
  final int _rowCount = 10;
  int _total = 0;

  bool _isLoading = false;
  bool _hasInitialLoadFinished = false;

  bool get _hasData => _items.isNotEmpty;

  bool get _hasMore => _items.length < _total;

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

  void _onTapItem(GenericListItem<Map<String, dynamic>> item) async {
    if (item.data == null) {
      /// puedes manejar error o simplemente salir
      return;
    }

    final controller = ProductModalController();
    await controller.init();
    final draft = ProductMapper.fromMap(item.data!);
    controller.loadAndValidate(draft);

    final catalogMeasureData = await PosMockData.getCatalogMeasureData();
    final catalogTaxData = await PosMockData.getCatalogTaxData();

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
  }

  final controller = ProductModalController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_hasInitialLoadFinished && _isLoading)
          const Center(child: CircularProgressIndicator())
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
              final controller = ProductModalController();
              await controller.init();
              final catalogMeasureData =
                  await PosMockData.getCatalogMeasureData();
              final catalogTaxData = await PosMockData.getCatalogTaxData();

              showManagerProduct(
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
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_hasMore || _isLoading ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = _items[index];

          return InkWell(
            onTap: () => _onTapItem(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    // 👈 importante para que la imagen respete el círculo
                    child: item.image == null
                        ? Icon(
                            Sections.getIconItems(PosItemsSection.items),
                            color: Colors.grey,
                          )
                        : Image.network(
                            item.image!,
                            fit: BoxFit.cover,

                            // 🔄 Mientras carga
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;

                              return Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },

                            // ❌ Si falla
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Sections.getIconItems(PosItemsSection.items),
                                color: Colors.grey,
                              );
                            },
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
}

enum ProductViewMode {
  dialog,
  page,
}
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
final allowModal=viewMode == ProductViewMode.dialog;
  final content = AnimatedBuilder(
    animation: controller,
    builder: (_, __) {
      return PsModalLayout(
        useDialog:allowModal,
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
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
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
  return Column(
    children: [
      /// =========================
      /// 📦 INFORMACIÓN
      /// =========================
      PsSectionCard(
        title: "Información General",
        child: Column(
          children: [
            PsFieldRow(
              children: [
                /// 🔥 NOMBRE
                PsInput(
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
                Center(
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
              ],
            ),

            AppSpacing.spaceBetweenInputs,

            PsFieldRow(
              children: [
                /// 🔥 CATEGORÍA
                PsDropdown(
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
              ],
            ),

            AppSpacing.spaceBetweenInputs,
            PsFieldRow(
              children: [
                PsInput(
                  requiredField: true,
                  label: "REF",
                  value: controller.ref,
                  keyboardType: TextInputType.text,
                  onChanged: controller.setRef,
                  error: controller.refError,
                  isTouched: controller.refTouched,
                  isValid: controller.refError == null,
                ),
                PsInput(
                  requiredField: true,
                  label: "Codigo de Barras",
                  value: controller.codeBar,
                  keyboardType: TextInputType.text,
                  onChanged: controller.setCodeBar,
                  error: controller.codeBarError,
                  isTouched: controller.codeBarTouched,
                  isValid: controller.codeBarError == null,
                ),
              ],
            ),
            AppSpacing.spaceBetweenInputs,
          ],
        ),
      ),
      AppSpacing.spaceBetweenSections,

      PsSectionCard(
        title: "Costos y Precios",
        child: Column(
          children: [
            /// 🔥 PRECIO + COSTE
            PsFieldRow(
              children: [
                PsDropdown<TaxCategoryModel>(
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

                PsInput(
                  value: controller.price.toString(),
                  requiredField: true,
                  label: "Precio",
                  keyboardType: TextInputType.number,
                  onChanged: controller.setPrice,
                  error: controller.priceError,
                  isTouched: controller.priceTouched,
                  isValid: controller.priceError == null,
                ),
                PsInput(
                  requiredField: true,
                  value: controller.cost.toString(),

                  label: "Coste",
                  keyboardType: TextInputType.number,
                  onChanged: controller.setCost,
                  error: controller.costError,
                  isTouched: controller.costTouched,
                  isValid: controller.costError == null,
                ),
              ],
            ),
          ],
        ),
      ),

      /// =========================
      /// 📦 INVENTARIO
      /// =========================
      PsSectionCard(
        title: "Inventario Inicial",
        child: Column(
          children: [
            PsFieldRow(
              children: [
                PsSellTypeSelector(
                  value: controller.sellType,
                  onChanged: controller.setSellType,
                ),
                _buildMeasureWidget(
                  controller.sellType,
                  listMeasureCategory,
                  controller,
                ),
              ],
            ),

            PsFieldRow(
              children: [
                PsInput(
                  requiredField: true,
                  value: controller.stock.toString(),
                  label: "Stock",
                  keyboardType: TextInputType.number,
                  onChanged: controller.setStock,
                  isTouched: controller.stockTouched,
                  error: controller.stockError,
                  isValid: controller.stockError == null,
                ),
                PsInput(
                  value: controller.lowStock.toString(),
                  requiredField: true,
                  label: "Stock mínimo",
                  keyboardType: TextInputType.number,
                  onChanged: controller.setLowStock,
                  error: controller.lowStockError,
                  isTouched: controller.lowStockTouched,
                  isValid: controller.lowStockError == null,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
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
