import 'package:flutter/material.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/services/media_picker_service.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../widgets/empty_data.dart';

import '../../../models/sections_data.dart';
import '../../../state/pos_items_controller.dart';
import '../../../state/product_modal_controller.dart';
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

  late FakeItemsApi _api;

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
    _api = FakeItemsApi(total: _simulatedTotal);
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
    _api = FakeItemsApi(total: _simulatedTotal);

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

  void _onTapItem(GenericListItem<Map<String, dynamic>> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.title),
        content: Text(
          'ID: ${item.id}\n'
          'Subtitle: ${item.subtitle}\n'
          'Description: ${item.description}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
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
              await showDialog(
                context: context,
                builder: (_) => AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return PsModalLayout(
                      title: "Producto",
                      onSave: controller.canSubmit
                          ? () {
                        if (controller.validate()) {
                          final product = controller.save();
                          Navigator.pop(context);
                        }
                      }
                          : null,

                      body: Column(
                        children: [
                          /// =========================
                          /// 📦 INFORMACIÓN
                          /// =========================
                          PsSectionCard(
                            title: "Información",
                            child: Column(
                              children: [
                                PsFieldRow(
                                  children: [
                                    /// 🔥 NOMBRE
                                    PsInput(
                                      label: "Nombre",
                                      requiredField: true,
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
                                          final mediaService =
                                              MediaPickerService();
                                          final file =
                                              await showImageSourceSelector(
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
                                      isValid:
                                          controller.selectedCategory != null,
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
                                      isValid:
                                          controller.selectedSubcategory !=
                                          null,
                                    ),
                                  ],
                                ),

                                AppSpacing.spaceBetweenInputs,
                                PsFieldRow(
                                  children: [
                                    PsInput(
                                      requiredField: true,
                                      label: "REF",
                                      keyboardType: TextInputType.text,
                                      onChanged: controller.setRef,
                                      error: controller.refError,
                                      isTouched: controller.refTouched,
                                      isValid:
                                      controller.refError == null ,
                                    ),
                                    PsInput(
                                      requiredField: true,
                                      label: "Codigo de Barras",
                                      keyboardType: TextInputType.text,
                                      onChanged: controller.setCodeBar,
                                      error: controller.codeBarError,
                                      isTouched: controller.codeBarTouched,
                                      isValid:
                                      controller.codeBarError == null ,
                                    ),
                                  ],
                                ),
                                /// 🔥 NUEVO COMPONENTE
                                PsSellTypeSelector(
                                  value: controller.sellType,
                                  onChanged: controller.setSellType,
                                ),
                                AppSpacing.spaceBetweenInputs,
                                /// 🔥 PRECIO + COSTE
                                PsFieldRow(
                                  children: [
                                    PsInput(
                                      requiredField: true,
                                      label: "Precio",
                                      keyboardType: TextInputType.number,
                                      onChanged: controller.setPrice,
                                      error: controller.priceError,
                                      isTouched: controller.priceTouched,
                                      isValid:
                                      controller.priceError == null ,
                                    ),
                                    PsInput(
                                      requiredField: true,
                                      label: "Coste",
                                      keyboardType: TextInputType.number,
                                      onChanged: controller.setCost,
                                      error: controller.costError,
                                      isTouched: controller.costTouched,
                                      isValid:
                                      controller.costError == null ,
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
                          PsSectionCard(
                            title: "Inventario",
                            child: Column(
                              children: [
                                PsFieldRow(
                                  children: [
                                    PsInput(
                                      requiredField: true,
                                      label: "Stock",
                                      keyboardType: TextInputType.number,
                                      onChanged: controller.setStock,
                                      isTouched: controller.stockTouched,
                                      error: controller.stockError,

                                      isValid:
                                      controller.stockError == null ,
                                    ),
                                    PsInput(
                                      requiredField: true,
                                      label: "Stock mínimo",
                                      keyboardType: TextInputType.number,
                                      onChanged: controller.setLowStock,
                                      error: controller.lowStockError,
                                      isTouched: controller.lowStockTouched,
                                      isValid:
                                      controller.lowStockError == null ,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                    child: item.image == null
                        ? Icon(
                            Sections.getIconItems(PosItemsSection.items),
                            color: Colors.grey,
                          )
                        : null,
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
