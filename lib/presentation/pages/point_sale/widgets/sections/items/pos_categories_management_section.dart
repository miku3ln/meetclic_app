import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_categories_management_section/category_management.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section.dart';
import '../../../../../../services/alert_manager.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/services/media_picker_service.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/utils/validators/validators.dart';
import '../../../../../widgets/empty_data.dart';

import '../../../../../widgets/loading_manager.dart';
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

class PosCategoriesManagementSection extends StatefulWidget {
  const PosCategoriesManagementSection({super.key});

  @override
  State<PosCategoriesManagementSection> createState() =>
      _PosCategoriesManagementSectionState();
}

class _PosCategoriesManagementSectionState
    extends State<PosCategoriesManagementSection> {
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

    await controller.init();
    final draft = ProductCategoryMapper.fromMap(item);
    controller.loadAndValidate(draft);
    await showManagementMainModal(
      context: context,
      btnSaveTitle: "Actualizar",
      btnCancelTitle: "Cancelar",
      barrierDismissible: false,
      controller: controller,
      title: "Actualizar Categoria",
      typeManagement: CrudType.update,
    );
  }

  final controller = CategoryModalController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_hasInitialLoadFinished && _isLoading)
          const Center(child: PosLoadingView())
        else if (!_hasData)
          RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 600,
                  child: EmptyData(
                    icon: Sections.getIconItems(PosItemsSection.categories),
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
              final controller = CategoryModalController();
              await controller.init();
              showManagementMainModal(
                barrierDismissible: false,
                context: context,
                controller: controller,
                btnSaveTitle: "Guardar",
                btnCancelTitle: "Cancelar",
                title: "Crear Categoria",
                typeManagement: CrudType.create,
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
              child: Center(child: PosLoadingView()),
            );
          }

          final item = _items[index];

          return PsHeaderWithBadge(
            title: item.title,
            badgeCount: item.countData,
            badgeText: "Artículos Prueba",
            imageUrl: item.image,
            onTap: () => _onTapItem(item),
          );
        },
      ),
    );
  }
}

Future<void> showManagementMainModal({
  required BuildContext context,
  required CategoryModalController controller,
  required String title,
  required String btnCancelTitle,
  required String btnSaveTitle,
  CrudType typeManagement = CrudType.update,
  required bool barrierDismissible,
}) async {
  final content = AnimatedBuilder(
    animation: controller,
    builder: (_, __) {
      return PsModalLayout(
        isLoading: controller.isLoading,
        useDialog: false,
        title: title,
        btnCancelTitle: btnCancelTitle,
        btnSaveTitle: btnSaveTitle,
        onSave: controller.canSubmit
            ? () async {
                if (controller.validateForm().success) {
                  controller.setLoading(true);
                  final resultSave = await controller.saveCategory(typeManagement);
                  if (!context.mounted) return;
                  if (resultSave.success) {
                    bool allowClose = true;
                    AlertService.success(context, message: resultSave.message);
                    if (allowClose) {
                      controller.setAllowReloadData(true);
                      Navigator.pop(context, resultSave);
                      controller.emit(ProductModalEvents.save, {
                        "allowReload": true,
                      });
                    }
                  } else {
                    AlertService.error(context, message: resultSave.message);
                  }
                  controller.setLoading(false);
                }
              }
            : null,
        body: _buildManagerCategory(context, controller, typeManagement, title),
      );
    },
  );

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

Widget _buildManagerCategory(
  BuildContext context,
  CategoryModalController controller,
  CrudType type,
  String title,
) {
  return SingleChildScrollView(
      child: Column(
    children: [
      AppSpacing.spaceBetweenSections,

      PsSectionSplit(
        leftFlex: 7,
        rightFlex: 3,

        left: PsSectionCard(
          title: controller.titleCardInformation,
          child: Column(
            children: [
              PsFieldRow(
                children: [
                  PsFieldItem(
                    child: PsInput(
                      label: controller.codeLabel,
                      requiredField: true,
                      value: controller.code,
                      onChanged: controller.setCode,
                      error: controller.codeError,
                      isTouched: controller.codeTouched,
                      isValid: controller.codeError == null,
                    ),
                  ),

                  PsFieldItem(
                    child: PsInput(
                      label: controller.descriptionLabel,
                      requiredField: true,
                      value: controller.description,
                      onChanged: controller.setDescription,
                      error: controller.descriptionError,
                      isTouched: controller.descriptionTouched,
                      isValid: controller.descriptionError == null,
                    ),
                  ),
                ],
              ),

              AppSpacing.spaceBetweenInputs,

              PsFieldRow(
                children: [
                  PsFieldItem(
                    child: PsInput(
                      label: controller.nameLabel,
                      requiredField: true,
                      value: controller.name,
                      onChanged: controller.setName,
                      error: controller.nameError,
                      isTouched: controller.nameTouched,
                      isValid: controller.nameError == null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        right: PsSectionCard(
          title: controller.imageLabel,
          child: Center(
            child: PsImagePicker(
              image: controller.image,
              error: controller.imageError,
              requiredField: true,
              isTouched: controller.imageTouched,
              isValid: controller.image != null,
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
            ),
          ),
        ),
      ),
    ],
  ));
}
