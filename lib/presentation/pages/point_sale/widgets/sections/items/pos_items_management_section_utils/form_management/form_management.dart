import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../../../../../services/alert_manager.dart';
import '../../../../../../../../shared/models/api_response.dart';
import '../../../../../../../../shared/pagination_response.dart';
import '../../../../../../../../shared/services/media_picker_service.dart';
import '../../../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../../../../shared/utils/util_common.dart';
import '../../../../../../../../shared/utils/validators/validators.dart';
import '../../../../../../../shared/responsive/device_gesture_observer.dart';
import '../../../../../../../widgets/cards/cards.dart';
import '../../../../../models/product_draft.dart';
import '../../../../../models/product_management_measure.dart';
import '../../../../../state/product_modal_controller.dart';
import '../../../../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../../../molecules/inputs/ps_dropdown.dart';
import '../../../../molecules/inputs/ps_field_row.dart';
import '../../../../molecules/inputs/ps_input.dart';
import '../../../../molecules/ps_image_picker.dart';
import '../../../../organisms/dialogs/product_modal.dart';
import '../../../../organisms/ps_toogle_group.dart';
import '../../../../recipe/item-card/PsRecipeRowData.dart';
import '../../../product/ps_section_card.dart';
import '../../pos_items_management_section.dart';
import '../util-manager.dart';

Future<void> showManagerProduct({
  required BuildContext context,
  required ProductModalController controller,
  required String title,
  required String btnCancelTitle,
  required String btnSaveTitle,
  required List<MeasureCategoryModel> listMeasureCategory,
  required List<TaxCategoryModel> listTaxCategory,
  CrudType typeManagement = CrudType.update,
  required bool barrierDismissible,
  ProductViewMode viewMode = ProductViewMode.page,
  int productId = -1,
}) async {
  final allowModal = viewMode == ProductViewMode.dialog;
  controller.setManagerInitProduct(typeManagement, productId);
  controller.setListMeasureCategory(listMeasureCategory);
  final content = AnimatedBuilder(
    animation: controller,
    builder: (_, __) {
      return PsModalLayout(
        isLoading: controller.isLoading,
        useDialog: allowModal,
        title: controller.titleManagement,
        btnCancelTitle: btnCancelTitle,
        btnSaveTitle: btnSaveTitle,
        allowActions: controller.allowActions,
        eventController: controller.eventModalProductController,
        onSave: controller.canSubmit
            ? () async {
                if (!controller.validateForm().success) {
                  return;
                }
                controller.setLoading(true);
                final resultSave = await controller.saveProduct(typeManagement);
                if (!context.mounted) return;
                if (resultSave.success) {
                  bool allowClose = controller.allowCloseModalBySave();
                  AlertService.success(context, message: resultSave.message);
                  if (allowClose) {
                    controller.setAllowReloadData(true);
                    Navigator.pop(context, resultSave);
                    controller.emit(ProductModalEvents.save, {
                      "allowReload": true,
                    });
                  } else {
                    final product = resultSave.data?['saved']['product'];
                    final productIdCurrent = product["id"];
                    controller.setManagerInitProduct(
                      CrudType.update,
                      productIdCurrent,
                    );
                    controller.setAllowReloadData(true);
                  }
                } else {
                  AlertService.error(context, message: resultSave.message);
                }
                controller.setLoading(false);
              }
            : null,
        body: _buildProductBody(
          context,
          controller,
          typeManagement,
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

class ProductManagerFormWidget extends StatelessWidget {
  final ProductModalController controller;
  final List<MeasureCategoryModel> listMeasureCategory;
  final List<TaxCategoryModel> listTaxCategory;
  final BuildContext buildContextParent;

  const ProductManagerFormWidget({
    super.key,
    required this.controller,
    required this.listMeasureCategory,
    required this.listTaxCategory,
    required this.buildContextParent,
  });

  @override
  Widget build(BuildContext context) {
    final device = DeviceGestureObserver.snapshotOf(context);

    switch (device.layoutType) {
      case LayoutType.mobilePortrait:
        return PortraitProductWidget(
          controller: controller,
          listMeasureCategory: listMeasureCategory,
          listTaxCategory: listTaxCategory,
          buildContextParent: buildContextParent,
        );
      case LayoutType.mobileLandscape:
        return LandProductWidget(
          controller: controller,
          listMeasureCategory: listMeasureCategory,
          listTaxCategory: listTaxCategory,
          buildContextParent: buildContextParent,
        );

      case LayoutType.tabletPortrait:
        return PortraitProductWidget(
          controller: controller,
          listMeasureCategory: listMeasureCategory,
          listTaxCategory: listTaxCategory,
          buildContextParent: buildContextParent,
        );

      case LayoutType.tabletLandscape:
        return LandProductWidget(
          controller: controller,
          listMeasureCategory: listMeasureCategory,
          listTaxCategory: listTaxCategory,
          buildContextParent: buildContextParent,
        );
    }
  }
}

class LandProductWidget extends StatelessWidget {
  final ProductModalController controller;
  final List<MeasureCategoryModel> listMeasureCategory;
  final List<TaxCategoryModel> listTaxCategory;
  final BuildContext buildContextParent;

  const LandProductWidget({
    super.key,
    required this.controller,
    required this.listMeasureCategory,
    required this.listTaxCategory,
    required this.buildContextParent,
  });

  @override
  Widget build(BuildContext context) {
    return _buildManagerProduct(
      controller,
      listMeasureCategory,
      listTaxCategory,
      context,
    );
  }
}

String labelCardInformationProduct(ProductModalController controller) {
  return controller.titleCardInformationProduct;
}

Widget _buildManagerProduct(
  ProductModalController controller,
  List<MeasureCategoryModel> listMeasureCategory,
  List<TaxCategoryModel> listTaxCategory,
  BuildContext context,
) {
  return Column(
    children: [
      AppSpacing.spaceBetweenSections,

      /// =========================
      /// 📦 INFORMACIÓN
      /// =========================
      PsSectionSplit(
        leftFlex: 7,
        rightFlex: 3,
        left: PsSectionCard(
          title: labelCardInformationProduct(controller),
          child: Column(
            children: [
              PsFieldRow(
                children: [
                  PsFieldItem(
                    child: PsToggleSelector<InventoryType>(
                      enabled:
                          controller.typeManagementProduct == CrudType.create,
                      title: controller.inventoryTypeLabel,
                      value: controller.inventoryType,
                      items: InventoryType.values,
                      onChanged: controller.setInventoryType,
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
                      label: controller.codeBarLabel,
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
                      label: controller.descriptionLabel,
                      value: controller.description,
                      keyboardType: TextInputType.text,
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
                    flex: 2,
                    child: PsInput(
                      label: controller.nameLabel,
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
                      label: controller.categoriesLabel,
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
                          label: controller.subcategoriesLabel,
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
          title: controller.titleCardCostPricesProduct,
          child: Column(
            children: [
              /// 🔥 PRECIO + COSTE
              PsFieldRow(
                children: [
                  PsFieldItem(
                    flex: 1,
                    child: PsDropdown<TaxCategoryModel>(
                      label: controller.taxsLabel,
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
                      value: controller.price?.toString() ?? '',
                      requiredField: true,
                      label: controller.priceLabel,
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
                      value: controller.cost?.toString() ?? '',
                      label: controller.getLabelPriceName(),
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
        //TODO
        title: controller.titleCardInventoryInitProduct, //oki
        child: Column(
          children: [
            PsFieldRow(
              children: [
                PsFieldItem(
                  child: _InventoryInfoHint(
                    type: controller.sellType,
                    listMeasureCategoryManagement:
                        controller.listMeasureCategoryManagement,
                  ),
                ),
              ],
            ),
            PsFieldRow(
              children: [
                PsFieldItem(
                  child: PsToggleSelector<MeasureType>(
                    title: controller.sellTypeLabel,
                    value: controller.sellType,
                    items: MeasureType.values,
                    enabled:
                        controller.typeManagementProduct == CrudType.create,
                    onChanged: controller.setMeasureType,
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
                    value: controller.stock?.toString() ?? '',
                    enabled:
                        controller.typeManagementProduct == CrudType.create,
                    label: controller.stockLabel,
                    keyboardType: TextInputType.number,
                    onChanged: controller.setStock,
                    isTouched: controller.stockTouched,
                    error: controller.stockError,
                    isValid: controller.stockError == null,
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
            AppSpacing.spaceBetweenInputs,
            PsFieldRow(
              children: [
                PsFieldItem(
                  child: PsInput(
                    value: controller.lowStock?.toString() ?? '',
                    requiredField: true,
                    label: controller.lowStockLabel,
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
  );
}

class PortraitProductWidget extends StatelessWidget {
  final ProductModalController controller;
  final List<MeasureCategoryModel> listMeasureCategory;
  final List<TaxCategoryModel> listTaxCategory;
  final BuildContext buildContextParent;

  const PortraitProductWidget({
    super.key,
    required this.controller,
    required this.listMeasureCategory,
    required this.listTaxCategory,
    required this.buildContextParent,
  });

  @override
  Widget build(BuildContext context) {
    return _buildManagerProduct(
      controller,
      listMeasureCategory,
      listTaxCategory,
      context,
    );
  }
}

Widget _buildProductBody(
  BuildContext context,
  ProductModalController controller,
  CrudType typeManagement,
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
    child: ProductManagerFormWidget(
      controller: controller,
      listMeasureCategory: listMeasureCategory,
      listTaxCategory: listTaxCategory,
      buildContextParent: context,
    ),
  );
}

Widget _buildTabRecipe(
  BuildContext context,
  ProductModalController controller,
  List<MeasureCategoryModel> listMeasureCategory,
) {
  final recipeEnabled =
      (controller.inventoryType == InventoryType.processed ||
          controller.inventoryType == InventoryType.forSale) &&
      controller.idManagementProduct > 0;

  return SingleChildScrollView(
    child: controller.idManagementProduct > 0
        ? PsSectionCard(
            title: labelCardInformationProduct(controller),
            child: Column(
              children: [
                recipeEnabled
                    ? PsSectionCard(
                        title: switch (controller.inventoryType) {
                          InventoryType.raw => 'Receta ',
                          InventoryType.processed => 'Receta',
                          InventoryType.forSale => 'Receta',
                        },
                        child: Column(
                          children: [
                            AppSpacing.spaceBetweenSections,
                            PsFieldRow(
                              children: [
                                /// 🔥 CATEGORÍA
                                PsFieldItem(
                                  child:
                                      PsApiTypeAhead<
                                        GenericListItem<Map<String, dynamic>>
                                      >(
                                        label:
                                            'Seleccione los Ingredientes para la receta.!',
                                        searchApi: (search) {
                                          final dataRecipe =
                                              PosMockData.getProductsRecipeSearch(
                                                searchPhrase: search,
                                                componentProductId: controller
                                                    .idManagementProduct,
                                                inventorType:
                                                    (controller
                                                            .inventoryType
                                                            .id ==
                                                        InventoryType
                                                            .processed
                                                            .id
                                                    ? InventoryType.raw.id
                                                    : ('${InventoryType.processed.id},${InventoryType.raw.id}')),
                                              );
                                          return dataRecipe;
                                        },
                                        getLabel: (e) {
                                          final title = e.title ?? '';
                                          final stock = e.data?['stock'] ?? 0;
                                          final code = e.data?['code'] ?? '';

                                          return '$code - $title';
                                        },
                                        onSelected: (item) {
                                          final product = item;
                                          controller.ingredientsController
                                              .addIngredient(product);
                                        },
                                      ),
                                ),
                              ],
                            ),
                            AppSpacing.spaceBetweenSections,
                            if (!controller.isLoadingDataRecipe &&
                                controller
                                    .ingredientsController
                                    .ingredients
                                    .isNotEmpty &&
                                false)
                              PsFieldRow(
                                children: [
                                  PsFieldItem(
                                    child: PsToggleSelector<MeasureType>(
                                      title: controller.titleLabelTotalRecipe,
                                      value: controller.sellType,
                                      items: MeasureType.values,
                                      onChanged: controller.setMeasureType,
                                    ),
                                  ),
                                ],
                              ),
                            AppSpacing.spaceBetweenSections,
                            if (controller.isLoadingDataRecipe)
                              const Center(child: CircularProgressIndicator())
                            else if (controller
                                .ingredientsController
                                .ingredients
                                .isEmpty)
                              Center(
                                child: PsInfoCard(
                                  type: PsInfoCardType.simple,
                                  config: warningCard,
                                  icon: Icons.info_outline,
                                  title: 'Atención',
                                  description:
                                      'Ingrese al menos un producto a la receta, asi podra utilizar el producto.!',
                                  onClose: () {
                                    debugPrint('cerrar');
                                  },
                                ),
                              )
                            else
                              Column(
                                children: controller
                                    .ingredientsController
                                    .ingredients
                                    .map((e) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _buildRecipeItemRow(
                                          e,
                                          listMeasureCategory,
                                          controller,
                                          context,
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )
        : Text(
            controller.inventoryType == InventoryType.processed
                ? 'No ha registrado el Producto Procesado'
                : (controller.inventoryType == InventoryType.forSale
                      ? 'No ha registrado el Menu'
                      : ''),
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
  final resultData = getDataSubMeasureByMeasure(listMeasureCategory, type);
  final resultSet = resultData.measureCategory;
  final unitsWithConversions = resultData.units;
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

  final Function(RecipeIngredientItem item) onEdit;

  final Function(RecipeIngredientItem item) onDelete;

  const PsIngredientCard({
    super.key,
    required this.item,
    required this.measureCategories,
    required this.onQuantityChanged,
    required this.onUnitChanged,
    required this.onEdit,
    required this.onDelete,
  });

  List<UnitMeasureModel> getUnits(RecipeIngredientItem item) {
    List<UnitMeasureModel> resultList = [];
    if (measureCategories.isEmpty) {
    } else {
      final category = measureCategories.firstWhere(
        (e) => e.id.toString() == item.baseUnitMeasureId.toString(),
      );

      if (category == null) {
        resultList = [];
      } else {
        resultList = category.units;
      }
    }

    return resultList;
  }

  @override
  Widget build(BuildContext context) {
    var itemsInformation = getUnits(item);
    var itemMeasureSelect = item.inputUnit;
    final details = jsonDecode(item.allData!);
    final productMeasureTypeRoot = details['product_measure_type'];

    var informationProduct = item.name + "(" + item.code + " )";

    var typeMeasureId = productMeasureTypeRoot['id'].toString();
    final configuration = MeasureTypeUtils.getConfiguration(
      typeMeasureId: typeMeasureId,
    );
    Color borderColor = configuration.borderColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: borderColor, width: 6)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          /// FILA 1
          PsSectionSplit(
            left: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  Text(informationProduct),
                  PsBadge(label: productMeasureTypeRoot['value']),
                ],
              ),
            ),
            right: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    onPressed: () => onEdit(item),
                    icon: const Icon(Icons.save_sharp),
                  ),
                  IconButton(
                    onPressed: () => onDelete(item),
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
                  value: item.quantityInput.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: onQuantityChanged,
                ),
              ),

              PsFieldItem(
                flex: 2,
                child: PsDropdown<UnitMeasureModel>(
                  label: item.inputUnit?.name ?? 'Unidad',
                  items: itemsInformation,
                  value: null,
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
  if (item.inputUnit == null || item.baseUnit == null) {
    return const SizedBox.shrink();
  }

  final baseValue = item.quantityInput * item.conversionFactor;

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
          '${baseValue.toStringAsFixed(2)} ${item.baseUnit!.symbol}',
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
  bool recipeLoaded = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.index == 1) {
        widget.controller.setAllowActions(false);
      } else {
        widget.controller.setAllowActions(true);
      }
      if (tabController.index == 1 && !recipeLoaded) {
        final recipeEnabled =
            widget.controller.inventoryType == InventoryType.processed ||
            widget.controller.inventoryType == InventoryType.forSale;

        if (recipeEnabled && widget.controller.idManagementProduct > 0) {
          recipeLoaded = true;
          widget.controller.ingredientsController.loadRecipe();
        } else {}
      } else {
        recipeLoaded = false;
      }
    });
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
            const Tab(text: 'Producto', icon: Icon(Icons.inventory_2_outlined)),
            Tab(
              text: recipeEnabled ? 'Receta' : '',
              icon: Icon(
                recipeEnabled ? Icons.restaurant_menu : Icons.lock_outline,
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
                  : Center(
                      child: PsInfoCard(
                        widthPercent: 100,
                        type: PsInfoCardType.simple,
                        config: warningCard,
                        icon: Icons.info_outline,
                        title: 'Atención',
                        description:
                            'Disponible únicamente para productos que se agregan recetas.!',
                        onClose: () {
                          debugPrint('cerrar');
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildRecipeItemRow(
  RecipeIngredientItem item,
  List<MeasureCategoryModel> listMeasureCategory,
  ProductModalController controller,
  BuildContext context,
) {
  //CREATE  item.recipeId==0
  //UPDATE item.recipeId>0
  Color managerCrudColorBackground = Colors.green;
  Color managerCrudColorText = Colors.green.shade100;
  var e = item;
  var managerCrudRegisterIcon = Icons.save_outlined;
  String managerCrudText = "Creacion";
  final colorsApp = AppThemeTokens.of(context);
  var managerTypeMeasureIcon = Icons.restaurant;
  var managerTypeMeasureText = "";
  Color managerTypeMeasureColor = Colors.orange;
  final details = jsonDecode(item.allData!);
  final productMeasureTypeRoot = details['product_measure_type'];
  var informationProduct = item.name + "(" + item.code + " )";
  Color borderColor = Colors.green;
  var typeMeasureId = productMeasureTypeRoot['id'].toString();

  final configuration = MeasureTypeUtils.getConfiguration(
    typeMeasureId: typeMeasureId,
  );
  borderColor = configuration.borderColor;
  managerTypeMeasureIcon = configuration.icon;
  managerTypeMeasureText = configuration.text;
  managerTypeMeasureColor = borderColor;

  if (item.recipeId > 0) {
    managerCrudColorBackground = colorsApp.badgeText;
    managerCrudColorText = AppColors.shade(colorsApp.badgeText, 50);
    managerCrudText = "Actualizacion ";
    managerCrudRegisterIcon = Icons.edit;
  }

  List<UnitMeasureModel> itemsInformation = getUnits(item, listMeasureCategory);
  int i = 0;
  return PsRecipeRowItem<UnitMeasureModel>(
    data: PsRecipeRowData<UnitMeasureModel>(
      leftBorderColor: borderColor,
      title: informationProduct,
      badgeTitle: managerCrudText,
      badgeBackground: managerCrudColorText,
      badgeTextColor: managerCrudColorBackground,
      item: item,
      measureCategories: listMeasureCategory,
      actions: [
        PsRecipeAction(
          icon: managerCrudRegisterIcon,
          color: controller.ingredientsController.canSaveIngredient(item)
              ? colorsApp.badgeText
              : AppColors.shade(colorsApp.badgeText, 50),
          onPressed: controller.ingredientsController.canSaveIngredient(item)
              ? () async {
                  final response = await controller.ingredientsController
                      .managerRegisterIngrediente(item, context);
                  if (response.success) {
                    controller.setAllowReloadData(true);
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(response.message)));
                }
              : null,
        ),
        PsRecipeAction(
          icon: Icons.delete,
          color: Colors.red,
          onPressed: () {
            controller.ingredientsController.removeIngredient(item, context);
          },
        ),
      ],

      leading: PsRecipeLeading(
        icon: managerTypeMeasureIcon,
        title: managerTypeMeasureText,
        backgroundColor: managerTypeMeasureColor,
      ),
      inputLabel: "Cantidad",
      inputValue: item.quantityInput.toString(),
      onInputChanged: (value) {
        controller.ingredientsController.updateIngredientQuantity(e, value);
      },
      dropdownLabel: controller.sellTypeLabel,
      dropdownItems: itemsInformation,
      dropdownValue: itemsInformation.first,
      dropdownItemLabel: (e) => '${e.name} (${e.symbol})',
      onDropdownChanged: (value) async {
        await controller.ingredientsController.updateIngredientUnit(e, value);
      },
      equivalenceTitle: "Equiv.",
      equivalenceValue: "0.25 Kg",
      footerItems: [
        // PsRecipeFooterItem(title: "Código", value: "ING-001"),
        // PsRecipeFooterItem(title: "Stock", value: "50 Kg"),
      ],
    ),
  );
}

List<UnitMeasureModel> getUnits(
  RecipeIngredientItem item,
  List<MeasureCategoryModel> measureCategories,
) {
  List<UnitMeasureModel> resultList = [];
  if (measureCategories.isEmpty) {
  } else {
    final category = measureCategories.firstWhere(
      (e) => e.id.toString() == item.baseUnitMeasureId.toString(),
    );

    if (category == null) {
      resultList = [];
    } else {
      resultList = category.units;
    }
  }

  return resultList;
}

class _InventoryInfoHint extends StatelessWidget {
  final MeasureType type;
  final List<MeasureCategoryModel> listMeasureCategoryManagement;

  const _InventoryInfoHint({
    required this.type,
    required this.listMeasureCategoryManagement,
  });

  @override
  Widget build(BuildContext context) {
    final allowView = type.id == MeasureType.unit.id ? false : true;
    if (allowView) {
      final resultData = getDataSubMeasureByMeasure(
        listMeasureCategoryManagement,
        type,
      );
      final baseUnit = resultData.measureCategory.baseUnit;
      final units = resultData.units;
      final exampleValue = 10;
      final exampleUnit = units.firstWhere(
        (u) => !u.isBase,
        orElse: () => units.first,
      );
      final convertedValue = exampleValue * exampleUnit.factorToBase;
      return InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(
                  'Conversión de inventario (${resultData.measureCategory.name})',
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🧭 BASE UNIT
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Unidad base: ${baseUnit.name} (${baseUnit.symbol})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Matriz de conversión:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 8),

                      // 📊 TABLE
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(3),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Color(0xFFF3F4F6)),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text('Unidad'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text('Factor'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text('Ejemplo (10)'),
                              ),
                            ],
                          ),

                          ...units.map((u) {
                            final example = (10 * u.factorToBase);
                            final isBase = u.isBase;
                            final isDefault = u.isDefault;
                            return TableRow(
                              decoration: BoxDecoration(
                                color: isBase
                                    ? const Color(0xFFEFF6FF) // azul base
                                    : isDefault
                                    ? const Color(0xFFF0FDF4) // verde default
                                    : null,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    children: [
                                      Text('${u.name} (${u.symbol})'),

                                      const SizedBox(width: 6),

                                      if (isBase) _badge('BASE', Colors.blue),

                                      if (isDefault && !isBase)
                                        _badge('DEFAULT', Colors.green),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(u.factorToBase.toString()),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    '10 ${u.symbol} = ${(10 * u.factorToBase)} ${baseUnit.symbol}',
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 🔁 EXPLANATION
                      Text(
                        'Ejemplo:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 6),

                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Todo ingreso o egreso en el sistema se convierte automáticamente a ',
                            ),

                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: _badge(baseUnit.symbol, Colors.blue),
                            ),

                            const TextSpan(text: '. Por ejemplo, si ingresas '),

                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: _badge(
                                '$exampleValue ${exampleUnit.symbol}',
                                Colors.green,
                              ),
                            ),

                            const TextSpan(text: ', se almacenará como '),

                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: _badge(
                                '$convertedValue ${baseUnit.symbol}',
                                Colors.blue,
                              ),
                            ),

                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido'),
                  ),
                ],
              );
            },
          );
        },
        child: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18),
              SizedBox(width: 4),
              Text(
                '¿Cómo funciona?',
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

Widget _badge(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
    ),
  );
}
