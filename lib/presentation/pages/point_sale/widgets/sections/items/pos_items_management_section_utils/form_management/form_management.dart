import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../services/alert_manager.dart';
import '../../../../../../../../shared/services/media_picker_service.dart';
import '../../../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../../../shared/theme/configuration/app_text_styles.dart';
import '../../../../../../../../shared/theme/configuration/app_theme_tokens.dart';
import '../../../../../../../../shared/utils/validators/validators.dart';
import '../../../../../../../shared/responsive/device_gesture_observer.dart';
import '../../../../../models/product_management_measure.dart';
import '../../../../../state/product_modal_controller.dart';
import '../../../../molecules/inputs/ps_dropdown.dart';
import '../../../../molecules/inputs/ps_field_row.dart';
import '../../../../molecules/inputs/ps_input.dart';
import '../../../../molecules/ps_image_picker.dart';
import '../../../../organisms/dialogs/product_modal.dart';
import '../../../../organisms/ps_toogle_group.dart';
import '../../../product/ps_section_card.dart';
import '../../pos_items_management_section.dart';

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

  final content = AnimatedBuilder(
    animation: controller,
    builder: (_, __) {
      return PsModalLayout(
        useDialog: allowModal,
        title: controller.titleManagement,
        btnCancelTitle: btnCancelTitle,
        btnSaveTitle: btnSaveTitle,
        onSave: controller.canSubmit
            ? () async {
                if (!controller.validateForm().success) {
                  return;
                }
                final resultSave = await controller.saveProduct(typeManagement);
                if (!context.mounted) return;
                if (resultSave.success) {
                  bool allowClose = controller.allowCloseModalBySave();
                  AlertService.success(context, message: resultSave.message);
                  if (allowClose) {
                    Navigator.pop(context, resultSave);
                  } else {
                    final product = resultSave.data?['saved']['product'];
                    final productIdCurrent=product["id"];
                    controller.setManagerInitProduct(CrudType.update, productIdCurrent);
                  }
                } else {
                  AlertService.error(context, message: resultSave.message);
                }
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
        return Text('mobilePortrait');

      case LayoutType.mobileLandscape:
        return Text('mobileLandscape');

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
                        value: controller.price.toString(),
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
                        value: controller.cost.toString(),
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
          title: controller.titleCardInventoryInitProduct,
          child: Column(
            children: [
              PsFieldRow(
                children: [
                  PsFieldItem(
                    child: PsToggleSelector<MeasureType>(
                      title: controller.sellTypeLabel,
                      value: controller.sellType,
                      items: MeasureType.values,
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
                      value: controller.stock.toString(),
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
                      value: controller.lowStock.toString(),
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
}

String labelCardInformationProduct(ProductModalController controller) {
  return controller.titleCardInformationProduct;
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
                        value: controller.price.toString(),
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
                        value: controller.cost.toString(),
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
          title: controller.titleCardInventoryInitProduct,
          child: Column(
            children: [
              PsFieldRow(
                children: [
                  PsFieldItem(
                    child: PsToggleSelector<MeasureType>(
                      title: controller.sellTypeLabel,
                      value: controller.sellType,
                      items: MeasureType.values,
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
                      value: controller.stock.toString(),
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
                      value: controller.lowStock.toString(),
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

  controller.setListMeasureCategory(listMeasureCategory);
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
                                  child: PsDropdown(
                                    label: switch (controller.inventoryType) {
                                      InventoryType.raw => '',
                                      InventoryType.processed =>
                                        controller
                                            .titleLabelProductProcessedRecipe,
                                      InventoryType.forSale =>
                                        controller
                                            .titleLabelProductForSaleRecipe,
                                    },
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
                                ),
                              ],
                            ),
                            AppSpacing.spaceBetweenSections,
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
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final e = controller.ingredients[index];
                                  return PsIngredientCard(
                                    item: e,
                                    measureCategories: listMeasureCategory,
                                    onQuantityChanged: (value) {
                                      controller.updateIngredientQuantity(
                                        e,
                                        value,
                                      );
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
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )
        : Text(controller.inventoryType == InventoryType.processed?'No ha registrado el Producto Procesado':(controller.inventoryType == InventoryType.forSale?'No ha registrado el Menu':'') ),
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

    tabController = TabController(length: 2, vsync: this);
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
