import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section_utils/filters/filters_management_main.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section_utils/form_management/form_management.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section_utils/pos_items_controller.dart';
import '../../../../../../shared/pagination_response.dart';
import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/utils/validators/validators.dart';
import '../../../../../../shared/widgets/modals/manager-process-micro/ManagerProcessMicroConfig.dart';
import '../../../../../../shared/widgets/modals/manager-process-micro/ManagerProcessMicroResult.dart';
import '../../../../../../shared/widgets/modals/manager-process-micro/show_manager_process_micro.dart';
import '../../../../../../shared/widgets/search_filter/controller/search_filter_controller.dart';
import '../../../../../../shared/widgets/search_filter/controller/search_filter_events.dart';
import '../../../../../../shared/widgets/search_filter/models/search_filter_result.dart';
import '../../../../../../shared/widgets/search_filter/search_filter_widget.dart';
import '../../../../../widgets/cards/cards.dart';
import '../../../../../widgets/empty_data.dart';
import '../../../../../widgets/loading_manager.dart';
import '../../../../../widgets/toogle-manager.dart';
import '../../../models/product_draft.dart';
import '../../../state/product_modal_controller.dart';
import '../../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../molecules/inputs/ps_dropdown.dart';
import '../../molecules/inputs/ps_field_row.dart';
import '../../molecules/inputs/ps_input.dart';
import '../../organisms/items/pos_items_content.dart';
import '../../organisms/ps_toogle_group.dart';
import '../product/ps_section_card.dart';

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
  late PosItemsManagementRepository _api;
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
  final searchController = SearchFilterController(); //TODO SEARCH
  StreamSubscription? _searchSub; //TODO SEARCH
  void _listenSearchEvents() {
    //TODO SEARCH
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
    debugPrint(
      '🟢 INIT PosItemsManagementSection '
      '${identityHashCode(this)}',
    );

    _api = PosItemsManagementRepository(total: _simulatedTotal);
    _loadInitial();
    _scrollController.addListener(_onScroll);
    _listenSearchEvents(); //TODO SEARCH
  }

  @override
  void dispose() {
    debugPrint(
      '⚫ DISPOSE PosItemsManagementSection '
      '${identityHashCode(this)}',
    );

    _scrollController.dispose();
    _searchController.dispose();
    _modalSub?.cancel();
    _modalActions?.cancel();

    _searchSub?.cancel(); //TODO SEARCH
    searchController.dispose(); //TODO SEARCH
    super.dispose();
  }

  Future<void> _loadInitial() async {
    debugPrint('🟠 LOAD INITIAL ${identityHashCode(this)}');
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
    debugPrint('🔴🔴🔴 REFRESH ALL');

    if (_isLoading) return;
    _api = PosItemsManagementRepository(total: _simulatedTotal);

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

  Future<void> _onTypeManagement(
    GenericListItem<Map<String, dynamic>> item,
    int type,
  ) async {
    if (type == 0) {
      await _onTapItem(item);
    } else if (type == 1) {
    } else if (type == 2) {
      final draft = ProductMapper.fromMap(item.data!);
      final details = jsonDecode(draft.detailsAll!);
      var product_sell_config = details['product_sell_config'];
      var product_recipe_yield = details['product_recipe_yield'];
      final selectedUnitMeasure = draft.selectedUnitMeasure;
      final title = "Movimiento de inventario: ${draft.name}";
      bool allowYield = allowYieldManager(draft.inventoryType);

      String? titleYield = "";
      String? titleAmount = "";
      titleAmount = "Ingrese valores en ${selectedUnitMeasure?.symbol}";
      int? unitMeasureId = -1;
      if (product_recipe_yield == null && allowYield) {
      } else {}
      if (allowYield) {}

      final controller = InventoryMovementMicroController(
        allowYield: allowYield,
        amountLabelText: titleAmount,
        allowManagement: !(product_recipe_yield == null && allowYield),
      );
      if (draft.detailsAll?.isNotEmpty == true) {
        var allowShopCurrent = product_sell_config["allow_shop"];
        final allowShop = allowShopCurrent == 1;
        final productCurrent = details['product'];
        final productByStock = details['product_by_stock'];
        final lowStockField = (productByStock['min'] ?? 0).toDouble();
        final maxStockField = (productByStock['max'] ?? 0).toDouble();
        final descriptionField = productCurrent['description'];

        /// UNIT MEASURE
        unitMeasureId = selectedUnitMeasure?.id;
        final taxData = details['tax'];
        final taxId = taxData['id'];
        if (draft.sellType.id == MeasureType.unit.id) {
        } else {}
      }

      if (draft.category.id > 0 && draft.subcategory.id > 0) {}
      final result = await showManagerProcessMicro<Map<String, dynamic>>(
        context: context,
        config: ManagerProcessMicroConfig(
          title: title,
          description: 'Registra un ingreso o egreso del producto.',
          icon: Icons.inventory_2_outlined,
          submitText: 'Guardar',
          cancelText: 'Cancelar',
        ),

        form: ProductManagementMicroForm(
          controller: controller,
          itemProduct: item,
        ),

        listenable: controller,

        canSubmit: () => controller.canSubmit,
        onSubmit: () async {
          final validation = controller.validateFields();

          // 1. Validación local
          if (!validation.success) {
            return ManagerProcessMicroResult<Map<String, dynamic>>(
              success: false,
              data: validation.errors,
              message: validation.message,
              type: 'validation',
            );
          }

          // 2. Ejecutar movimiento en API
          final response = await PosMockData.generateMovementProduct(
            productId: draft.id!,
            typeMovement: controller.movementTypeValue,
            amount: controller.amountValue,
            amountYield: controller.amountYieldValue,
            unitMeasureId: unitMeasureId!,
          );

          // 3. API respondió con error
          if (!response.success) {
            return ManagerProcessMicroResult<Map<String, dynamic>>(
              success: false,
              data: response.data,
              message: response.message,
              type: 'error',
            );
          }

          // 4. Movimiento realizado correctamente
          return ManagerProcessMicroResult<Map<String, dynamic>>(
            success: true,
            data: response.data,
            message: response.message,
            type: 'save',
          );
        },
      );
      controller.dispose();
      if (!context.mounted) {
        return;
      }

      // ============================================================
      // ERROR
      // ============================================================

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty
                  ? result.message
                  : 'No se pudo realizar el movimiento.',
            ),
          ),
        );

        return;
      }

      switch (result.type) {
        case 'save':
          await _refreshAll();
          if (!context.mounted) {
            return;
          }

          // Mensaje después de terminar TODO
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message.isNotEmpty
                    ? result.message
                    : 'Movimiento de inventario realizado correctamente.',
              ),
            ),
          );
          break;

        case 'close':
          debugPrint('Cerrar SIN reload');
          break;

        case 'cancel':
          debugPrint('Cancelar SIN reload');
          break;
      }

      return;
    } else if (type == 3) {}
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
    debugPrint('🟡 BUILD ${identityHashCode(this)}');

    return Stack(
      children: [
        IgnorePointer(
          ignoring: _isOpeningProduct,
          child: Column(children: [_buildHeader(), _buildBody()]),
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
                  listMeasureCategory: controller.listMeasureCategoryManagement,
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

  Widget _buildBody() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          debugPrint('🔥 REFRESH INDICATOR ACTIVADO');
          await _refreshAll();
        },
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
                    onTap: () => _onTypeManagement(item, 0),
                    onEdit: () => _onTypeManagement(item, 0),
                    onManage: () => _onTypeManagement(item, 2),
                    onReport: () => _onTypeManagement(item, 3),
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

class DialogResult<T> {
  final bool success;
  final T? data;
  final String message;
  final String type;

  const DialogResult({
    required this.success,
    this.data,
    this.message = '',
    required this.type,
  });
}

class InventoryMovementMicroController extends BaseFormController {
  static const String movementTypeIncome = 'INCOME';
  static const String movementTypeOutcome = 'OUTCOME';

  final bool allowYield;
  final bool allowManagement;
  final String allowManagementMessage;

  late final FormFieldController<String> movementTypeField;
  late final FormFieldController<double> amountField;
  FormFieldController<double>? amountYieldField;
  final String movementTypeLabelText;
  final String amountLabelText;
  final String amountYieldLabelText;

  InventoryMovementMicroController({
    this.allowYield = false,
    this.allowManagement = false,
    this.allowManagementMessage = "",
    this.movementTypeLabelText = 'Tipo de movimiento',
    this.amountLabelText = 'Cantidad',
    this.amountYieldLabelText = 'Cantidad que genera en unidades',
  }) {
    movementTypeField = FormFieldController<String>(
      label: movementTypeLabelText,
      value: movementTypeIncome,
      validators: [ValidatorsUtil.required(movementTypeLabelText)],
    );

    amountField = FormFieldController<double>(
      label: amountLabelText,
      validators: [ValidatorsUtil.positiveDouble(amountLabelText)],
    );

    fields.addAll({'movementType': movementTypeField, 'amount': amountField});

    if (allowYield) {
      amountYieldField = FormFieldController<double>(
        label: amountYieldLabelText,
        validators: [ValidatorsUtil.positiveDouble(amountYieldLabelText)],
      );

      fields['amountYield'] = amountYieldField!;
    }
  }

  String? get movementType => movementTypeField.value;

  double? get amount => amountField.value;

  double? get amountYield => amountYieldField?.value;

  String get movementTypeLabel => movementTypeField.label;

  String get amountLabel => amountField.label;

  String get amountYieldLabel =>
      amountYieldField?.label ?? 'Cantidad de rendimiento';

  String? get movementTypeError => movementTypeField.error;

  String? get amountError => amountField.error;

  String? get amountYieldError => amountYieldField?.error;

  bool get movementTypeTouched => movementTypeField.touched;

  bool get amountTouched => amountField.touched;

  bool get amountYieldTouched => amountYieldField?.touched ?? false;

  void setMovementType(String? value) {
    movementTypeField.setValue(value);
    notifyListeners();
  }

  void setAmount(String value) {
    amountField.setValue(double.tryParse(value));
    notifyListeners();
  }

  void setAmountYield(String value) {
    if (!allowYield || amountYieldField == null) {
      return;
    }

    amountYieldField!.setValue(double.tryParse(value));
    notifyListeners();
  }

  Map<String, dynamic> toPayload() {
    return {
      'type_movement': movementType,
      'amount': amount,
      if (allowYield) 'amount_yield': amountYield,
    };
  }

  int get movementTypeValue {
    return movementType == movementTypeIncome ? 1 : 0;
  }

  double get amountValue {
    return amount ?? 0;
  }

  int get amountYieldValue {
    return amountYield?.toInt() ?? 1;
  }

  bool get canSubmit {
    if (!allowManagement) {
      return false;
    }

    for (final field in fields.values) {
      if (field is FormFieldController) {
        if (!field.isValid) {
          return false;
        }
      }
    }

    return true;
  }
}

bool allowYieldManager(InventoryType inventoryType) {
  bool allowYield = false;
  if (InventoryType.raw.id == inventoryType.id) {
  } else if (InventoryType.processed.id == inventoryType.id) {
    allowYield = true;
  } else if (InventoryType.forSale.id == inventoryType.id) {
    allowYield = true;
  }

  return allowYield;
}

class ProductManagementMicroForm extends StatelessWidget {
  final InventoryMovementMicroController controller;
  final GenericListItem<Map<String, dynamic>> itemProduct;

  const ProductManagementMicroForm({
    super.key,
    required this.controller,
    required this.itemProduct,
  });

  @override
  Widget build(BuildContext context) {
    final draft = ProductMapper.fromMap(itemProduct.data!);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final bool showMovementForm = controller.allowManagement;

        final List<Widget> listForms = [
          PsFieldRow(
            children: [
              PsFieldItem(
                child: PsSegmentToggle<String>(
                  title: controller.movementTypeLabel,
                  value: controller.movementType!,
                  titleSpacing: 20,
                  itemPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(3),
                  iconSize: 18,
                  spacing: 5,
                  borderRadius: 10,
                  height: 40,
                  itemMinWidth: 70,
                  titleStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  items: const [
                    PsSegmentItem<String>(
                      value:
                          InventoryMovementMicroController.movementTypeIncome,
                      label: 'Ingreso',
                      activeIcon: Icons.add_circle,
                      inactiveIcon: Icons.add_circle_outline,
                      thumbColor: Colors.green,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),
                    PsSegmentItem<String>(
                      value:
                          InventoryMovementMicroController.movementTypeOutcome,
                      label: 'Egreso',
                      activeIcon: Icons.remove_circle,
                      inactiveIcon: Icons.remove_circle_outline,
                      thumbColor: Colors.orange,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                    ),
                  ],
                  onChanged: controller.setMovementType,
                ),
              ),
            ],
          ),

          AppSpacing.spaceBetweenInputs,

          PsFieldRow(
            children: [
              PsFieldItem(
                child: PsInput(
                  label: controller.amountLabel,
                  value: formatInput(controller.amount),
                  requiredField: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: controller.setAmount,
                  error: controller.amountError,
                  isTouched: controller.amountTouched,
                  isValid: controller.amountError == null,
                ),
              ),
            ],
          ),
        ];

        if (controller.allowYield) {
          listForms.add(AppSpacing.spaceBetweenInputs);

          listForms.add(
            PsFieldRow(
              children: [
                PsFieldItem(
                  flex: 1,
                  child: PsInput(
                    value: formatInput(controller.amountYield),
                    requiredField: true,
                    label: controller.amountYieldLabel,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: controller.setAmountYield,
                    error: controller.amountYieldError,
                    isTouched: controller.amountYieldTouched,
                    isValid: controller.amountYieldError == null,
                  ),
                ),
              ],
            ),
          );
        }

        final List<Widget> movementFields = showMovementForm
            ? listForms
            : [
                Center(
                  child: PsInfoCard(
                    widthPercent: 100,
                    type: PsInfoCardType.simple,
                    config: warningCard,
                    icon: Icons.info_outline,
                    title: 'Atención',
                    description: 'No existe configuración de unidades que genera la receta.!',
                    onClose: () {
                      debugPrint('cerrar');
                    },
                  ),
                ),
              ];

        return PsSectionCard(
          title: 'Movimiento de inventario',
          child: Column(
            children: [
              AppSpacing.spaceBetweenInputs,

              ...movementFields,
            ],
          ),
        );
      },
    );
  }
}
