import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/models/product_management_measure.dart';
import '../../../../domain/services/session_service.dart';
import '../../../../shared/models/api_response.dart';
import '../../../../shared/pagination_response.dart';
import '../../../../shared/utils/validators/validators.dart';
import '../models/product_category.dart';
import '../models/product_draft.dart';
import '../models/product_subcategory.dart';
import '../repositories/config_repository.dart';
import '../services/product_catalog_service.dart';
import '../widgets/dialogs/moda_managerl.dart';
import '../widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../widgets/molecules/ps_image_picker.dart';
import '../widgets/organisms/ps_toogle_group.dart';
import 'dart:convert';

import '../widgets/sections/items/pos_categories_management_section/models/models_management.dart';

class ProductIngredientsController extends ChangeNotifier {
  final ProductModalController parent;

  ProductIngredientsController(this.parent);

  Future<void> loadRecipe() async {
    parent.setLoadingDataRecipe(true);
    final ingredientsData = await PosMockData.getProductsRecipeData(
      parent.idManagementProduct,
      parent.listMeasureCategoryData,
    );
    parent.setLoadingDataRecipe(false);
    ingredients = [];
    ingredients = ingredientsData;
    updateProcess();
  }

  late List<RecipeIngredientItem> ingredients = [];

  /// =========================
  /// ✍️ SETTERS
  /// =========================
  void addIngredient(GenericListItem<Map<String, dynamic>> item) {
    final data = item.data!;
    final details = jsonDecode(data['details_all']);
    final product = details['product'];
    final defaultUnit = details['default_unit_measure'];
    final itemAdd = RecipeIngredientItem(
      recipeId: 0,
      // nuevo, aún no existe en BD
      productId: product['id'],
      name: product['name'],
      code: product['code_product'] ?? '',
      inventoryType: product['inventory_type'],
      productType: product['product_type'],

      /// inicialmente vacío
      quantityInput: 0,
      quantityBase: 0,
      conversionFactor: double.parse(defaultUnit['factor_to_base'].toString()),
      unitInputId: defaultUnit['id'],
      baseUnitMeasureId: product['product_measure_type_id'],
      inputUnit: UnitMeasureModel(
        id: defaultUnit['id'],
        name: defaultUnit['name'],
        symbol: defaultUnit['symbol'],
        factorToBase: double.parse(defaultUnit['factor_to_base'].toString()),
        isBase: defaultUnit['is_base'] == 1,
        isDefault: true,
        decimalPrecision: defaultUnit['decimal_precision'],
        conversions: const [],
      ),
      baseUnit: UnitMeasureModel(
        id: defaultUnit['id'],
        name: defaultUnit['name'],
        symbol: defaultUnit['symbol'],
        factorToBase: double.parse(defaultUnit['factor_to_base'].toString()),
        isBase: true,
        isDefault: true,
        decimalPrecision: defaultUnit['decimal_precision'],
        conversions: const [],
      ),
      allData: data['details_all'],
    );

    late int information = 1;

    ingredients = [itemAdd, ...ingredients];

    updateProcess();
  }

  void updateIngredientQuantity(RecipeIngredientItem item, String value) {
    item.quantityInput = double.tryParse(value) ?? 0;
    updateProcess();
  }

  void updateProcess() {
    notifyListeners();
    parent.notifyListeners();
  }

  Future<void> updateIngredientUnit(
    RecipeIngredientItem item,
    UnitMeasureModel? unit,
  ) async {
    if (unit == null) return;
    item.inputUnit = unit;
    item.unitInputId = unit.id;
    item.conversionFactor = unit.factorToBase;
    item.quantityBase = item.quantityInput * unit.factorToBase;
    updateProcess();
  }

  Future<dynamic> managerRegisterIngrediente(
    RecipeIngredientItem item,
    BuildContext context,
  ) async {
    final result = await PosMockData.saveProductRecipe(
      recipeId: item.recipeId,
      componentProductId: parent.idManagementProduct,
      productId: item.productId,
      quantityInput: item.quantityInput,
      quantityBase: item.quantityBase,
      conversionFactor: item.conversionFactor,
      unitInputId: item.unitInputId,
      baseUnitMeasureId: item.baseUnitMeasureId,
    );
    return result;
  }

  void removeIngredient(RecipeIngredientItem item, context) async {
    if (item.recipeId <= 0) {
      ingredients.removeWhere((e) => e.productId == item.productId);
      notifyListeners();
      parent.notifyListeners();
    } else {
      final result = await showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Eliminar ingrediente'),
            content: Text('¿Desea eliminar ${item.name} de la receta?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          );
        },
      );

      if (result == true) {}
    }
  }

  bool canSaveIngredient(RecipeIngredientItem item) {
    var result = item.quantityInput > 0 && item.unitInputId > 0;

    return result;
  }

  bool isNewIngredient(RecipeIngredientItem item) {
    return item.recipeId <= 0;
  }

  String getActionText(RecipeIngredientItem item) {
    return item.recipeId <= 0 ? 'Guardar' : 'Actualizar';
  }

  IconData getActionIcon(RecipeIngredientItem item) {
    return item.recipeId <= 0 ? Icons.save : Icons.edit;
  }
}

class ProductModalController extends BaseFormController {
  final _eventController = StreamController<ManagementModalEvent>.broadcast();

  Stream<ManagementModalEvent> get events => _eventController.stream;

  void emit(String type, [dynamic data]) {
    _eventController.add(ManagementModalEvent(type, data));
  }

  final _eventModalProductController =
      StreamController<ManagementModalEvent>.broadcast();

  Stream<ManagementModalEvent> get eventsModalProduct =>
      _eventModalProductController.stream;

  StreamController<ManagementModalEvent> get eventModalProductController =>
      _eventModalProductController;

  late final ProductIngredientsController ingredientsController;

  void initField() {
    fields.addAll({
      'name': FormFieldController<String>(
        label: 'Nombre',
        validators: [
          ValidatorsUtil.required("Nombre"),
          ValidatorsUtil.minLength(3),
        ],
      ),
      'description': FormFieldController<String>(
        label: 'Descripcion',
        validators: [
          ValidatorsUtil.required("Descripcion"),
          ValidatorsUtil.minLength(3),
        ],
      ),

      'codeBar': FormFieldController<String>(
        label: 'Codigo',
        validators: [
          ValidatorsUtil.required("Código"),
          ValidatorsUtil.alphanumeric(),
        ],
      ),

      'price': FormFieldController<double>(
        label: 'Precio Venta',
        validators: [ValidatorsUtil.positiveDouble("Precio")],
      ),

      'cost': FormFieldController<double>(
        label: 'Costo',
        validators: [ValidatorsUtil.nonNegativeDouble("Costo")],
      ),

      'stock': FormFieldController<double>(
        label: 'Stock',
        validators: [ValidatorsUtil.nonNegativeDouble("Stock")],
      ),

      'lowStock': FormFieldController<double>(
        label: 'Stock Minimo',
        validators: [ValidatorsUtil.nonNegativeDouble("Stock mínimo")],
      ),
      'maxStock': FormFieldController<double>(
        label: 'Stock Maximo',
        validators: [ValidatorsUtil.nonNegativeDouble("Stock maximo")],
      ),
    });

    inventoryType = InventoryType.raw;
    sellType = MeasureType.unit;
    ingredientsController.ingredients=[];
  }

  ProductModalController() {
    ingredientsController = ProductIngredientsController(this);
  }

  FormFieldController<String> get nameField =>
      field<FormFieldController<String>>('name');

  FormFieldController<String> get descriptionField =>
      field<FormFieldController<String>>('description');

  FormFieldController<String> get codeBarField =>
      field<FormFieldController<String>>('codeBar');

  FormFieldController<double> get priceField =>
      field<FormFieldController<double>>('price');

  FormFieldController<double> get costField =>
      field<FormFieldController<double>>('cost');

  FormFieldController<double> get stockField =>
      field<FormFieldController<double>>('stock');

  FormFieldController<double> get lowStockField =>
      field<FormFieldController<double>>('lowStock');

  FormFieldController<double> get maxStockField =>
      field<FormFieldController<double>>('maxStock');

  String get name => nameField.value ?? '';

  String? get description => descriptionField.value;

  String? get codeBar => codeBarField.value;

  double? get price => priceField.value;

  double? get cost => costField.value;

  double? get stock => stockField.value;

  double? get lowStock => lowStockField.value;

  double? get maxStock => maxStockField.value;

  String? get nameError => nameField.error;

  String? get descriptionError => descriptionField.error;

  String? get codeBarError => codeBarField.error;

  String? get priceError => priceField.error;

  String? get costError => costField.error;

  String? get stockError => stockField.error;

  String? get lowStockError => lowStockField.error;

  String? get maxStockError => maxStockField.error;

  bool get nameTouched => nameField.touched;

  bool get descriptionTouched => descriptionField.touched;

  bool get codeBarTouched => codeBarField.touched;

  bool get priceTouched => priceField.touched;

  bool get costTouched => costField.touched;

  bool get stockTouched => stockField.touched;

  bool get lowStockTouched => lowStockField.touched;

  bool get maxStockTouched => maxStockField.touched;

  /// =========================
  /// 🧾 DATA
  /// =========================

  String priceLabel = 'Precio Venta';
  String costLabel = 'Precio Compra';
  String costProductionLabel = 'Precio Costo';
  String stockLabel = 'Stock';
  String lowStockLabel = 'Stock Minimo';
  String maxStockLabel = 'Stock Maximo';

  String descriptionLabel = 'Descripcion';
  String codeBarLabel = 'Codigo';
  String categoriesLabel = 'Categoria';
  String subcategoriesLabel = 'Subcategoria';
  String taxsLabel = 'Impuesto';
  String stateLabel = 'Estado';

  String imageLabel = 'Imagen';
  String sellTypeLabel = 'Tipos de Medida';

  /// =========================
  /// 👆 TOUCHED
  /// =========================
  bool imageTouched = false;
  bool categoryTouched = false;
  bool subcategoryTouched = false;
  bool measureCategoryTouched = false;
  bool taxTouched = false;
  bool allowReloadData = false;

  /// =========================
  /// ⚠️ ERRORS
  /// =========================

  String? categoryError;
  String? subcategoryError;
  String? measureCategoryError;
  String? taxCategoryError;
  String? imageError;

  /// =========================
  /// 📂 CATEGORY
  /// =========================
  final _service = ProductCatalogService();

  List<ProductCategory> categories = [];
  List<ProductSubcategory> subcategories = [];
  List<TaxCategoryModel> taxs = [];

  ProductCategory? selectedCategory;
  ProductSubcategory? selectedSubcategory;
  MeasureCategoryModel? selectedMeasureCategory;
  TaxCategoryModel? selectedTaxCategory;

  /// =========================
  /// 🖼 IMAGE
  /// =========================
  Object? image;

  /// =========================
  /// 🧠 INIT
  /// =========================
  Future<void> init() async {
    categories = await _service.getCategories();
    final catalogMeasureData = await PosMockData.getCatalogMeasureData();
    final catalogTaxData = await PosMockData.getCatalogTaxData();
    setManagerDataManagementProduct(catalogMeasureData, catalogTaxData);

    notifyListeners();
  }

  void setPrice(String value) {
    priceField.setValue(value.isEmpty ? null : double.tryParse(value));
    notifyListeners();
  }

  void setCost(String value) {
    costField.setValue(value.isEmpty ? null : double.tryParse(value));
    notifyListeners();
  }

  void setStock(String value) {
    stockField.setValue(value.isEmpty ? null : double.tryParse(value));
    notifyListeners();
  }

  void setLowStock(String value) {
    lowStockField.setValue(value.isEmpty ? null : double.tryParse(value));
    notifyListeners();
  }

  void setMaxStock(String value) {
    maxStockField.setValue(value.isEmpty ? null : double.tryParse(value));
    notifyListeners();
  }

  void setDescription(String value) {
    descriptionField.setValue(value);
    notifyListeners();
  }

  void setCodeBar(String value) {
    codeBarField.setValue(value);
    notifyListeners();
  }

  void setAllowReloadData(bool value) {
    allowReloadData = value;
    notifyListeners();
  }

  /// =========================
  /// 📂 CATEGORY
  /// =========================

  Future<void> selectCategory(ProductCategory? category) async {
    categoryTouched = true;
    selectedCategory = category;
    selectedSubcategory = null;
    subcategories = [];
    categoryError = category == null ? "Selecciona una categoría" : null;
    subcategoryError = "Selecciona una subcategoría";

    if (category != null) {
      subcategories = category.subcategories;
    }

    notifyListeners();
  }

  void selectSubcategory(ProductSubcategory? sub) {
    subcategoryTouched = true;
    selectedSubcategory = sub;
    subcategoryError = sub == null ? "Selecciona una subcategoría" : null;
    notifyListeners();
  }

  UnitMeasureModel? selectedUnitMeasure;

  void selectUnitsByMeasure(UnitMeasureModel? unit) {
    measureCategoryTouched = true;
    selectedUnitMeasure = unit;
    measureCategoryError = unit == null
        ? "Selecciona una unidad de medida"
        : null;
    notifyListeners();
  }

  TaxCategoryModel? selectedTax;
  final List<StateModel<String>> states = [
    const StateModel<String>(
      id: 'ACTIVE',
      name: 'Activo',
      description: 'Registro activo',
    ),
    const StateModel<String>(
      id: 'INACTIVE',
      name: 'Inactivo',
      description: 'Registro inactivo',
    ),
  ];
  StateModel? selectedState = StateModel<String>(
    id: 'ACTIVE',
    name: 'Activo',
    description: 'Registro activo',
  );

  void selectState(StateModel? selectData) {
    selectedState = selectData;
    notifyListeners();
  }

  void selectTax(TaxCategoryModel? selectData) {
    taxTouched = true;
    selectedTax = selectData;
    taxCategoryError = selectData == null ? "Selecciona Iva" : null;
    notifyListeners();
  }

  /// =========================
  /// 🖼 IMAGE
  /// =========================
  void setImage(File file) {
    image = file;
    imageTouched = true;
    imageError = null;
    notifyListeners();
  }

  void removeImage() {
    image = null;
    imageTouched = true;
    imageError = "Imagen requerida";
    notifyListeners();
  }

  void setName(String value) {
    nameField.setValue(value);
    notifyListeners();
  }

  /// =========================
  /// ✅ VALIDATE ALL
  /// =========================
  bool submitted = false;

  ValidationResult validateForm() {
    submitted = true;
    super.validate();
    categoryError = selectedCategory == null
        ? "Selecciona una categoría"
        : null;

    subcategoryError = selectedSubcategory == null
        ? "Selecciona una subcategoría"
        : null;

    imageError = image == null ? "Imagen requerida" : null;
    final errors = {
      'name': nameError,
      'price': priceError,
      'cost': costError,
      'stock': stockError,
      'lowStock': lowStockError,
      'maxStock': maxStockError,
      'description': descriptionError,
      'codeBar': codeBarError,
      'category': categoryError,
      'subcategory': subcategoryError,
      'image': imageError,
    };
    final hasErrors = errors.values.any((e) => e != null);
    notifyListeners();
    return ValidationResult(
      success: !hasErrors,
      errors: errors,
      message: hasErrors ? "Formulario inválido" : "Formulario válido",
    );
  }

  CrudType mode = CrudType.create;

  /// =========================
  /// 🧠 FORM STATE
  /// =========================
  bool get canSubmit {
    if (mode == CrudType.update) {
      return validateForm().success;
    }
    return isFormValid &&
        nameTouched &&
        priceTouched &&
        costTouched &&
        stockTouched &&
        lowStockTouched &&
        maxStockTouched &&
        descriptionTouched &&
        codeBarTouched &&
        imageTouched &&
        categoryTouched &&
        subcategoryTouched;
  }

  bool get isFormValid {
    return [
      nameError,
      priceError,
      costError,
      stockError,
      lowStockError,
      maxStockError,
      descriptionError,
      codeBarError,
      categoryError,
      subcategoryError,
      imageError,
    ].every((e) => e == null);
  }

  CrudType typeManagementProduct = CrudType.create;
  int idManagementProduct = -1;
  String titleManagement = "";

  List<MeasureCategoryModel> listMeasureCategoryManagement = [];
  List<TaxCategoryModel> listTaxCategoryManagement = [];

  void setManagerDataManagementProduct(
    List<MeasureCategoryModel> listMeasureCategory,
    List<TaxCategoryModel> listTaxCategory,
  ) {
    listMeasureCategoryManagement = listMeasureCategory;
    listTaxCategoryManagement = listTaxCategory;

    notifyListeners();
  }

  void setManagerInitProduct(CrudType typeManagement, int productId) {
    typeManagementProduct = typeManagement;
    idManagementProduct = productId;
    if (typeManagement == CrudType.create) {
      titleManagement = "Crear Producto";
    } else {
      titleManagement = "Actualizar Producto";
    }
    notifyListeners();
  }

  String getLabelPriceName() {
    if (InventoryType.raw == inventoryType) {
      return costLabel;
    } else if (InventoryType.processed == inventoryType) {
      return costProductionLabel;
    }
    return costProductionLabel + "d";
  }

  bool allowCloseModalBySave() {
    if (InventoryType.raw == inventoryType) {
      return true;
    } else if (InventoryType.processed == inventoryType) {
      return false;
    }
    return false;
  }

  MeasureType sellType = MeasureType.unit;

  bool sellTypeAllowManagement = true; // viene de configuración o permiso

  bool get canManageSellType =>
      typeManagementProduct == CrudType.create && sellTypeAllowManagement;

  TypeDesgloce sellTypeDesgloce = TypeDesgloce.menuRecipe;
  bool allowShopManagement = true;

  bool allowManagementViewAllowShop() {
    if (sellType.id == MeasureType.unit.id) {
      return true;
    } else {
      return false;
    }
  }

  void setMeasureType(MeasureType type) {
    sellType = type;
    selectedUnitMeasure = null;
    allowShopManagement = allowManagementViewAllowShop();
    if (sellType.id == MeasureType.unit.id) {
      if (!allowShop) {
        allowShop = true;
      }
    } else {
      if (allowShop) {
        allowShop = false;
      }
    }

    notifyListeners();
  }

  InventoryType inventoryType = InventoryType.raw;
  String inventoryTypeLabel = 'Tipo de Producto';
  String nameLabel = 'Nombre';
  String titleCardInformationProduct = 'Informacion General';
  String titleCardConfigurationProduct = 'Configuracion';

  bool allowManagerMeasure = false;
  bool allowShop = false;

  String titleCardCostPricesProduct = 'Costos y Precios';
  String titleCardInventoryInitProduct = 'Inventario Inicial';
  String titleCardInventoryStockManagement = 'Stock Gestion';

  String titleCardProcessedProductRecipe = 'Receta - Materias Primas';
  String titleCardForSaleProductRecipe = 'Receta - Productos Procesados';
  String titleLabelProductProcessedRecipe = 'Materia Prima';
  String titleLabelProductForSaleRecipe = 'Productos Procesados';
  String titleLabelTotalRecipe = 'Total de Tipos de Productos Agregados';

  void setInventoryType(InventoryType type) {
    inventoryType = type;

    if (inventoryType.id == InventoryType.raw.id) {
      sellTypeAllowManagement = true;
      lowStockField.value = null;
      maxStockField.value = null;
      stockField.value = null;
    } else if (inventoryType.id == InventoryType.processed.id) {
      sellTypeAllowManagement = true;
      lowStockField.value = null;
      maxStockField.value = null;
      stockField.value = null;
    } else if (inventoryType.id == InventoryType.forSale.id) {
      sellTypeAllowManagement = false;
      sellType = MeasureType.unit;
      lowStockField.value = 0;
      maxStockField.value = 0;
      stockField.value = 0;
    }

    notifyListeners();
  }

  void setViewAllowShop(bool value) {
    allowShop = value;
    notifyListeners();
  }

  void setDesgloce(TypeDesgloce type) {
    sellTypeDesgloce = type;
    notifyListeners();
  }

  int productId = 0;

  void loadAndValidate(ProductDraft draft) {
    loadDataModel(draft);
  }

  void loadDataModel(ProductDraft draft) async {
    mode = CrudType.update;
    productId = draft.id!;

    /// =========================
    /// 🧾 DATA
    /// =========================
    nameField.value = draft.name;
    priceField.value = draft.price;
    costField.value = draft.cost;
    stockField.value = draft.stock;

    String? stateCurrent = draft.state;
    StateModel<String>? selectedStateResult = states.firstWhere(
      (state) => state.id == stateCurrent,
    );

    selectedState = selectedStateResult;
    codeBarField.value = draft.code;
    inventoryType = draft.inventoryType;
    if (draft.detailsAll?.isNotEmpty == true) {
      final details = jsonDecode(draft.detailsAll!);
    var product_sell_config=details['product_sell_config'];

    var allowShopCurrent=product_sell_config["allow_shop"];
      allowShop=allowShopCurrent==1;
      final productCurrent = details['product'];
      final productByStock = details['product_by_stock'];
      lowStockField.value = (productByStock['min'] ?? 0).toDouble();
      maxStockField.value = (productByStock['max'] ?? 0).toDouble();

      descriptionField.value = productCurrent['description'];

      /// UNIT MEASURE
      final unitMeasureId = details['default_unit_measure']?['id'];
      final taxData = details['tax'];
      final taxId = taxData['id'];

      selectedTax = listTaxCategoryManagement.firstWhere((e) => e.id == taxId);
      //selectedUnitMeasure=draft.selectedUnitMeasure;
      if (draft.sellType.id == MeasureType.unit.id) {
      } else {
        final resultData = getDataSubMeasureByMeasure(
          listMeasureCategoryManagement,
          draft.sellType,
        );

        final unitsWithConversions = resultData.units.firstWhere(
          (unit) => unit.id == draft.selectedUnitMeasure?.id,
        );

        if (unitsWithConversions.id > 0) {
          selectedUnitMeasure = unitsWithConversions;
        }
      }

      if (false) {
        selectedTax = TaxCategoryModel(
          id: taxData['id'],
          name: taxData['value'],
          description: '',
          priority: 0,
          taxPercentage: taxData['percentage'],
        );
        if (unitMeasureId != null) {
          for (final category in listMeasureCategoryData) {
            try {
              selectedUnitMeasure = category.units.firstWhere(
                (e) => e.id == unitMeasureId,
              );
              break;
            } catch (_) {}
          }
        }

        /// MEASURE TYPE
        final measureTypeId = details['product_measure_type']?['id'];

        if (measureTypeId != null) {
          sellType = MeasureType.values.firstWhere(
            (e) => e.id == measureTypeId.toString(),
            orElse: () => MeasureType.unit,
          );
        }
      }
    }

    if (draft.category.id > 0) {
      selectedCategory = categories.firstWhere(
        (c) => c.id == draft.category.id,
        orElse: () => ProductCategory.empty(),
      );
      subcategories = selectedCategory!.subcategories;
      if (draft.subcategory.id > 0) {
        var needleSearch = subcategories.firstWhere(
          (s) => s.id == draft.subcategory.id,
          orElse: () => ProductSubcategory.empty(),
        );
        if (needleSearch.id > 0) {
          selectedSubcategory = needleSearch;
        }
      }
    }

    image = draft.image;
    sellType = draft.sellType;

    /// =========================
    /// ⚠️ RESET TOUCH
    /// =========================

    imageTouched = false;
    categoryTouched = false;
    subcategoryTouched = false;

    /// =========================
    /// ❌ RESET ERRORES
    /// =========================

    categoryError = null;
    subcategoryError = null;
    imageError = null;

    validate();
    notifyListeners();
  }

  /// =========================
  /// 💾 get Data Recipe
  /// =========================
  bool _isLoadingDataRecipe = false;

  bool get isLoadingDataRecipe => _isLoadingDataRecipe;

  void setLoadingDataRecipe(bool value) {
    _isLoadingDataRecipe = value;
    notifyListeners();
  }

  /// =========================
  /// 💾 SAVE
  /// =========================
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _allowActions = true;

  bool get allowActions => _allowActions;

  void setAllowActions(bool value) {
    _allowActions = value;
    notifyListeners();
  }

  void resetProcess() {
    _allowActions = true;
    notifyListeners();
  }

  Future<ApiResponse<Map<String, dynamic>>> saveProduct(CrudType type) async {
    if (!validateForm().success) {
      throw Exception("Formulario inválido");
    }
    final imageManager = ImageMapper.map(image);

    final File? setImageCrud = imageManager.type == ImageSourceType.file
        ? imageManager.source as File
        : null;
    var payload = buildPayload(type);
    if (type == CrudType.create) {
      final response = await ProductDataUtil.createProduct(
        payload,
        image: setImageCrud,
      );
      return response;
    }
    final response = await ProductDataUtil.updateProduct(
      payload,
      image: setImageCrud,
    );
    return response;
  }

  void resetAllForm() {
    initField();
    _resetTouched();
    _resetErrors();
    resetValues();
  }

  void resetValues() {
    selectedTax = null;
    selectedCategory = null;
    selectedSubcategory = null;
    selectedMeasureCategory = null;
    selectedTaxCategory = null;
    image = null;
  }

  void _resetTouched() {
    nameField.touched = false;
    priceField.touched = false;
    costField.touched = false;
    stockField.touched = false;
    lowStockField.touched = false;
    descriptionField.touched = false;
    codeBarField.touched = false;
    imageTouched = false;
    categoryTouched = false;
    subcategoryTouched = false;
  }

  void _resetErrors() {
    nameField.error = null;
    priceField.error = null;
    costField.error = null;
    stockField.error = null;
    lowStockField.error = null;
    descriptionField.error = null;
    codeBarField.error = null;
    categoryError = null;
    subcategoryError = null;
    imageError = null;
  }

  Map<String, dynamic> buildPayload(CrudType type) {
    switch (inventoryType) {
      case InventoryType.raw:
        return _buildBasePayload(type);
      case InventoryType.processed:
        return _buildBasePayload(type);

      case InventoryType.forSale:
        return _buildBasePayload(type);
    }
  }

  List<MeasureCategoryModel> listMeasureCategoryData = [];

  Map<String, dynamic> buildInitialInventoryMeasure({
    required MeasureType measureType,
    required double stock,
    required List<MeasureCategoryModel> listMeasureCategory,
    UnitMeasureModel? selectedUnitMeasure,
  }) {
    final category = listMeasureCategory.firstWhere(
      (e) => e.id.toString() == measureType.id,
    );

    final baseUnit = category.baseUnit;

    double quantity = stock;
    int? unitMeasureId = selectedUnitMeasure?.id;
    double conversionFactor = 1;
    int? unit_input_id = 1;

    switch (measureType) {
      case MeasureType.unit:
        quantity = stock;
        unitMeasureId = baseUnit.id;
        unit_input_id = unitMeasureId;

        conversionFactor = 1;
        break;

      case MeasureType.mass:
      case MeasureType.volume:
      case MeasureType.length:
      case MeasureType.area:
        conversionFactor = selectedUnitMeasure?.factorToBase ?? 1;
        quantity = stock * conversionFactor;
        unitMeasureId = baseUnit.id;
        unit_input_id = selectedUnitMeasure?.id;
        break;
    }

    return {
      'quantity': quantity,
      'unit_measure_id': unitMeasureId,
      'quantity_input': stock,
      'unit_input_id': unit_input_id,
      'conversion_factor': conversionFactor,
      'descriptionerence_type': 'INVENTARIO_INICIAL',
      'descriptionerence_id': null,
      'description': 'Carga inicial',
    };
  }

  void setListMeasureCategory(List<MeasureCategoryModel> list) {
    listMeasureCategoryData = list;
    notifyListeners();
  }

  Map<String, dynamic> _buildBasePayload(CrudType type) {
    final businessId = SessionService().businessId;
    final currentSession = SessionService().currentSession;
    final user_id = currentSession?.userId;
    final hasTax = selectedTax!.taxPercentage > 0.0;
    final measureData = buildInitialInventoryMeasure(
      measureType: sellType,
      stock: stock!,
      selectedUnitMeasure: selectedUnitMeasure,
      listMeasureCategory: listMeasureCategoryData,
    );
    final product_measure_type_id = sellType.id;
    var stateCurrent = 'INACTIVE';
    var product_type = sellType.id;
    var inventory_type = inventoryType.id;
    if (type == CrudType.create) {
      stateCurrent = ingredientsController.ingredients.isNotEmpty
          ? 'ACTIVE'
          : 'INACTIVE';

      if (InventoryType.raw.id == inventory_type) {
        stateCurrent = 'ACTIVE';
      } else if (InventoryType.processed.id == inventory_type) {
        stateCurrent = 'INACTIVE';
      } else if (InventoryType.forSale.id == inventory_type) {
        stateCurrent = 'INACTIVE';
      }
    } else if (type == CrudType.update) {

      if (InventoryType.raw.id == inventory_type) {
        stateCurrent = selectedState?.id;
      } else if (InventoryType.processed.id == inventory_type ||InventoryType.forSale.id == inventory_type ) {
        stateCurrent = ingredientsController.ingredients.isNotEmpty
            ? 'ACTIVE'
            : 'INACTIVE';

      }
    }

    if (InventoryType.raw.id == inventory_type) {
      product_type = 'UNIT';
    } else if (InventoryType.processed.id == inventory_type) {
      product_type = 'MEASURABLE';
    } else if (InventoryType.forSale.id == inventory_type) {
      product_type = 'MIXED';
    }

    var product = {
      'code': codeBar,
      'name': name,
      'product_type': product_type,
      'inventory_type': inventoryType.id,
      'state': stateCurrent,
      'product_trademark_id': 1,
      'product_category_id': selectedCategory?.id,
      'product_subcategory_id': selectedSubcategory?.id,
      'source': '',
      'description': description,
      'code_provider': codeBar,
      'code_product': codeBar,
      'has_tax': hasTax ? 1 : 0,
      'is_service': 0,
      'user_id': user_id,
      'product_measure_type_id': product_measure_type_id,
      'view_online': 1,
    };
    if (type == CrudType.update) {
      product['id'] = productId;
    }
    var saveRegister = {
      'product': product,
      'business_by_products': {'business_id': businessId},
      'product_by_stock': {"min": lowStock, "max": maxStock},
      'product_inventory': {
        'business_id': businessId,
        'avarage_kardex_value': cost,
        'tax': hasTax ? 'SI' : 'NO',
        'quantity_units': stock,
        'sale_price': price,
        'total_price': ((price ?? 0) * (stock ?? 0)),
        'tax_id': selectedTax?.id,
        'profit': 30,
        'profit_type': 1,
        'note': 'descrip',
        'sale_price2': price,
        'sale_price3': price,
        'sale_price4': cost,
      },
      'product_sell_config': {
        'allow_pos': 1,
        'allow_shop':allowShop?1:0,
        'allow_delivery': 0,
        'visible': 1,
      },
      'inventory_movement': {
        //MANAGEMENT MEASURE CONFIG
        'quantity': measureData["quantity"],
        'unit_measure_id': measureData["unit_measure_id"],
        'quantity_input': measureData["quantity_input"],
        'unit_input_id': measureData["unit_input_id"],
        'conversion_factor': measureData["conversion_factor"],
        'descriptionerence_type': measureData["descriptionerence_type"],
        'descriptionerence_id': measureData["descriptionerence_id"],
        'description': measureData["description"],
      },
    };

    return saveRegister;
  }
}

extension on Double {
  operator >(int other) {}
}

class CategoriaModalController extends ChangeNotifier {
  /// =========================
  /// 🧾 DATA
  /// =========================
  String name = "";

  /// =========================
  /// 👆 TOUCHED
  /// =========================
  bool nameTouched = false;

  bool imageTouched = false;

  /// =========================
  /// ⚠️ ERRORS
  /// =========================
  String? nameError;
  String? imageError;

  /// =========================
  /// 🖼 IMAGE
  /// =========================
  File? image;

  /// =========================
  /// 🧠 INIT
  /// =========================
  Future<void> init() async {
    notifyListeners();
  }

  /// =========================
  /// ✍️ SETTERS
  /// =========================

  void setName(String value) {
    name = value;
    nameTouched = true;

    nameError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Nombre"),
      ValidatorsUtil.minLength(3),
    ]);

    notifyListeners();
  }

  void setImage(File file) {
    image = file;
    imageTouched = true;
    imageError = null;
    notifyListeners();
  }

  void removeImage() {
    image = null;
    imageTouched = true;
    imageError = "Imagen requerida";
    notifyListeners();
  }

  /// =========================
  /// ✅ VALIDATE ALL
  /// =========================
  bool submitted = false;

  ValidationResult validate() {
    submitted = true;

    /// =========================
    /// 🧠 NORMALIZADOR (FIX NULL)
    /// =========================
    String normalize(num? value) => value == null ? "" : value.toString();

    /// =========================
    /// 📦 MAP DE ERRORES
    /// =========================
    final errors = <String, String?>{
      /// TEXTOS
      'name': ValidatorsUtil.validate(name, [
        ValidatorsUtil.required("Nombre"),
      ]),
      'image': image == null ? "Imagen requerida" : null,
    };

    /// =========================
    /// 🔥 ASIGNAR A VARIABLES (CLAVE)
    /// =========================
    nameError = errors['name'];
    imageError = errors['image'];

    /// =========================
    /// ✅ RESULTADO FINAL
    /// =========================
    final hasErrors = errors.values.any((e) => e != null);
    notifyListeners();
    return ValidationResult(
      success: !hasErrors,
      errors: errors,
      message: hasErrors
          ? "Formulario inválido, revisa los campos"
          : "Formulario válido",
    );
  }

  CrudType mode = CrudType.create;

  /// =========================
  /// 🧠 FORM STATE
  /// =========================
  bool get canSubmit {
    if (mode == CrudType.update) {
      return validate().success;
    }

    return isFormValid && nameTouched && imageTouched;
  }

  bool get isFormValid {
    return [nameError, imageError].every((e) => e == null);
  }

  void loadAndValidate(ProductCategoryDraft draft) {
    load(draft);
  }

  void load(ProductCategoryDraft draft) async {
    mode = CrudType.update;

    /// =========================
    /// 🧾 DATA
    /// =========================
    name = draft.name;

    image = draft.image as File?;

    /// =========================
    /// ⚠️ RESET TOUCH
    /// =========================
    nameTouched = false;

    imageTouched = false;

    /// =========================
    /// ❌ RESET ERRORES
    /// =========================
    nameError = null;

    imageError = null;

    validate();
    notifyListeners();
  }

  /// =========================
  /// 💾 SAVE
  /// =========================

  ProductCategoryDraft save(CrudType type) {
    if (!validate().success) {
      throw Exception("Formulario inválido");
    }

    return ProductCategoryDraft(
      name: name,
      image: "",
      description: "",
      id: -1,
      business_id: -1,
      code: '',
      subtitle: '',
    );
  }

  void _resetTouched() {
    nameTouched = false;

    imageTouched = false;
  }

  void _resetErrors() {
    nameError = null;

    imageError = null;
  }
}

enum CustomerDetailTab { profile, redeem, purchases }

enum CustomerViewType { list, create, update, detail }

class CustomerModalController extends ChangeNotifier {
  /// =========================
  /// VIEW STATE
  /// =========================
  CustomerViewType view = CustomerViewType.list;

  /// =========================
  /// DATA
  /// =========================
  List<CustomerModelPosCurrent> customers = [];
  CustomerModelPosCurrent? selectedCustomer;

  /// =========================
  /// SEARCH
  /// =========================
  String search = "";

  void setSearch(String val) {
    search = val;
    notifyListeners();
  }

  void setTypeView(CustomerViewType val) {
    view = val;
    notifyListeners();
  }

  List<CustomerModelPosCurrent> get filteredCustomers {
    if (search.isEmpty) return customers;

    return customers
        .where((c) => c.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  bool initialized = false;

  /// =========================
  /// FORM DATA
  /// =========================
  String name = "";
  String email = "";
  String phone = "";
  String city = "";

  /// =========================
  /// TOUCHED
  /// =========================
  bool nameTouched = false;

  /// =========================
  /// ERRORS
  /// =========================
  String? nameError;

  /// =========================
  /// SETTERS
  /// =========================
  void setName(String val) {
    name = val;
    nameTouched = true;

    nameError = ValidatorsUtil.validate(val, [
      ValidatorsUtil.required("Nombre"),
      ValidatorsUtil.minLength(3),
    ]);

    notifyListeners();
  }

  void setEmail(String val) {
    email = val;
    notifyListeners();
  }

  void setPhone(String val) {
    phone = val;
    notifyListeners();
  }

  void setCity(String val) {
    city = val;
    notifyListeners();
  }

  /// =========================
  /// VALIDATION
  /// =========================
  bool get isFormValid => nameError == null && name.isNotEmpty;

  bool get canSubmit {
    if (view == CustomerViewType.create) {
      return isFormValid && nameTouched;
    }

    return false;
  }

  ValidationResult validate() {
    nameError = ValidatorsUtil.validate(name, [
      ValidatorsUtil.required("Nombre"),
    ]);

    notifyListeners();

    final success = nameError == null;

    return ValidationResult(
      success: success,
      errors: {'name': nameError},
      message: success ? "OK" : "Formulario inválido",
    );
  }

  /// =========================
  /// NAVIGATION
  /// =========================
  void goToCreate() {
    _resetForm();
    view = CustomerViewType.create;
    notifyListeners();
  }

  void goToDetail(CustomerModelPosCurrent c) {
    selectedCustomer = c;
    view = CustomerViewType.detail;
    notifyListeners();
  }

  void back() {
    /// 🔥 CASO ESPECIAL
    if (openedWithCustomer && view == CustomerViewType.detail) {
      openedWithCustomer = false;

      view = CustomerViewType.list;

      /// 👇 Cargar lista si no existe
      if (customers.isEmpty) {
        initLoadData();
      }

      notifyListeners();
      return;
    }

    /// NORMAL FLOW
    if (view == CustomerViewType.detail ||
        view == CustomerViewType.create ||
        view == CustomerViewType.update) {
      view = CustomerViewType.list;
    }

    notifyListeners();
  }

  /// =========================
  /// SAVE
  /// =========================
  CustomerModelPosCurrent save() {
    final customer = CustomerModelPosCurrent(
      id: DateTime.now().toString(),
      name: name,
      email: email,
      phone: phone,
      city: city,
    );

    customers.add(customer);

    view = CustomerViewType.list;

    notifyListeners();

    return customer;
  }

  void reset() {
    view = CustomerViewType.list;
    selectedCustomer = null;
    customerInTicket = null;
    detailTab = CustomerDetailTab.profile;
    initialized = false;
  }

  void _resetForm() {
    name = "";
    email = "";
    phone = "";
    city = "";

    nameTouched = false;
    nameError = null;
  }

  bool isSelectedInTicket = false;
  CustomerModelPosCurrent? customerInTicket;

  bool isCustomerSelected(CustomerModelPosCurrent c) {
    return customerInTicket?.id == c.id;
  }

  void toggleCustomerInTicket() {
    if (selectedCustomer == null) return;

    /// SI YA ES EL MISMO → QUITAR
    if (customerInTicket?.id == selectedCustomer!.id) {
      customerInTicket = null;
    } else {
      /// SI ES OTRO → REEMPLAZAR
      customerInTicket = selectedCustomer;
    }

    notifyListeners();
  }

  void setCustomerInitTicket(CustomerModelPosCurrent c) {
    customerInTicket = c;
    selectedCustomer = c;
    notifyListeners();
  }

  bool openedWithCustomer = false;

  void initWithCustomer(CustomerModelPosCurrent customer) {
    selectedCustomer = customer;
    customerInTicket = customer;

    openedWithCustomer = true; // 🔥 CLAVE
    view = CustomerViewType.detail;

    notifyListeners();
    selectedCustomer = customer;
    customerInTicket = customer;

    view = CustomerViewType.detail;

    notifyListeners();
  }

  CustomerDetailTab detailTab = CustomerDetailTab.profile;

  void setDetailTab(CustomerDetailTab tab) {
    detailTab = tab;
    notifyListeners();
  }

  CrudType mode = CrudType.create;

  void goToEdit() {
    final c = selectedCustomer;
    if (c == null) return;

    /// 👉 SET MODE
    mode = CrudType.update;

    /// 👉 CARGAR DATA
    name = c.name;
    email = c.email ?? "";
    phone = c.phone ?? "";
    city = c.city ?? "";

    /// 👉 RESET VALIDATION
    nameTouched = false;
    nameError = null;

    /// 👉 CAMBIAR VISTA
    view = CustomerViewType.update;

    notifyListeners();
  }

  final CustomerServiceModal _service;

  CustomerModalController(this._service);

  bool isLoading = false;
  String? errorMessage;

  Future<void> initLoadData() async {
    try {
      isLoading = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      final data = await _service.fetchCustomers();
      customers = data;
    } catch (e) {
      errorMessage = "Error al cargar clientes";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
