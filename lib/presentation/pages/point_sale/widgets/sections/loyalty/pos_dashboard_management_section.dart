import 'package:flutter/material.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/services/media_picker_service.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/utils/validators/validators.dart';
import '../../../../../widgets/empty_data.dart';

import '../../../models/product_draft.dart';
import '../../../models/sections_data.dart';
import '../../../state/pos_items_controller.dart';
import '../../../state/product_modal_controller.dart';

import '../../molecules/inputs/ps_field_row.dart';
import '../../molecules/inputs/ps_input.dart';
import '../../molecules/ps_image_picker.dart';
import '../../organisms/dialogs/product_modal.dart';
import '../../organisms/items/pos_items_content.dart';

import '../../templates/row_grid.dart';
import '../product/ps_section_card.dart';

class PosDashboardManagementSection extends StatefulWidget {
  const PosDashboardManagementSection({super.key});

  @override
  State<PosDashboardManagementSection> createState() =>
      _PosDashboardManagementSectionState();
}

class _PosDashboardManagementSectionState extends State<PosDashboardManagementSection> {
  final ScrollController _scrollController = ScrollController();

  /// aquí decides el total simulado
  int _simulatedTotal = 592;

  late FakeCategoriesApi _api;

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
    _api = FakeCategoriesApi(total: _simulatedTotal);
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
    _api = FakeCategoriesApi(total: _simulatedTotal);

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

  void _onTapItem( GenericListItem<Map<String, dynamic>>item) async {

    final controller = CategoriaModalController();
    await controller.init();
    final draft = ProductCategoryMapper.fromMap(item );
    controller.loadAndValidate(draft);
    await showProductModal(
      context: context,
      btnSaveTitle: "Actualizar",
      btnCancelTitle: "Cancelar",
      barrierDismissible: false,
      controller: controller,
      title: "Actualizar Categoria",
      type: CrudType.update,
    );
  }

  final controller = CategoriaModalController();

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
              children:  [
                SizedBox(
                  height: 600,
                  child: EmptyData(
                    icon:Sections.getIconItems(PosItemsSection.categories),
                    title: 'Todavía no hay Categorias',
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
              final controller = CategoriaModalController();
              await controller.init();
              showProductModal(
                barrierDismissible: false,
                context: context,
                controller: controller,
                btnSaveTitle: "Guardar",
                btnCancelTitle: "Cancelar",
                title: "Crear Categoria",
                type: CrudType.create,
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

          return  PsHeaderWithBadge(
            title: item.title,
            badgeCount: item.countData,
            badgeText: "Artículos",
            imageUrl:item.image,
            onTap: () => _onTapItem(item),
          );
        },
      ),
    );
  }
}



Future<void> showProductModal({
  required BuildContext context,
  required CategoriaModalController controller,
  required String title,
  required String btnCancelTitle,
  required String btnSaveTitle,

  CrudType type = CrudType.update,
  required bool barrierDismissible
}) async {
  await showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (_) => AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return PsModalLayout(
          title: title,
          btnCancelTitle: btnCancelTitle,
          btnSaveTitle: btnSaveTitle,
          onSave: controller.canSubmit
              ? () {
            if (controller.validate().success) {
              final product = controller.save(type);

              Navigator.pop(context);
            }
          }
              : null,
          body: _buildProductBody(context, controller, type, title),
        );
      },
    ),
  );
}

Widget _buildProductBody(
    BuildContext context,
    CategoriaModalController controller,
    CrudType type,
    String title,
    ) {
  return Column(
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


          ],
        ),
      ),
      AppSpacing.spaceBetweenSections,

      /// =========================
      /// 📦 INVENTARIO
      /// =========================
      type==CrudType.update? PsSectionCard(
        title: "Inventario",
        child: Column(
          children: [

          ],
        ),
      ):AppSpacing.spaceBetweenSections,
    ],
  );
}
