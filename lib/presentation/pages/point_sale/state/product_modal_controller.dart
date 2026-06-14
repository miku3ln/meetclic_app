import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:meetclic_app/presentation/pages/point_sale/models/product_management_measure.dart';

import '../../../../domain/services/session_service.dart';
import '../../../../shared/models/api_response.dart';
import '../../../../shared/utils/validators/validators.dart';
import '../models/product_category.dart';
import '../models/product_draft.dart';
import '../models/product_subcategory.dart';
import '../repositories/config_repository.dart';
import '../services/product_catalog_service.dart';
import '../widgets/dialogs/moda_managerl.dart';
import '../widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../widgets/organisms/ps_toogle_group.dart';

class ProductModalController extends ChangeNotifier {
  /// =========================
  /// 🧾 DATA
  /// =========================
  String name = "";
  double? price = 0;
  double? cost = 0;
  double? stock = 0;
  double? lowStock = 0;

  String? ref;
  String? codeBar;

  /// =========================
  /// 👆 TOUCHED
  /// =========================
  bool nameTouched = false;
  bool priceTouched = false;
  bool costTouched = false;
  bool stockTouched = false;
  bool lowStockTouched = false;
  bool refTouched = false;
  bool codeBarTouched = false;
  bool imageTouched = false;
  bool categoryTouched = false;
  bool subcategoryTouched = false;
  bool measureCategoryTouched = false;
  bool taxTouched = false;

  /// =========================
  /// ⚠️ ERRORS
  /// =========================
  String? nameError;
  String? priceError;
  String? costError;
  String? stockError;
  String? lowStockError;
  String? refError;
  String? codeBarError;
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
  File? image;

  /// =========================
  /// 🧠 INIT
  /// =========================
  Future<void> init() async {
    categories = await _service.getCategories();
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

  void updateIngredientQuantity(RecipeIngredientItem item, String value) {
    item.quantity = double.tryParse(value) ?? 0;

    notifyListeners();
  }

  void updateIngredientUnit(RecipeIngredientItem item, UnitMeasureModel? unit) {
    item.selectedUnit = unit;

    notifyListeners();
  }

  final List<RecipeIngredientItem> ingredients = [
    RecipeIngredientItem(
      name: 'Arroz',
      measureType: MeasureType.mass,
      quantity: 350,
    ),
    RecipeIngredientItem(
      name: 'Papa',
      measureType: MeasureType.mass,
      quantity: 75,
    ),
    RecipeIngredientItem(
      name: 'Pollo',
      measureType: MeasureType.unit,
      quantity: 1,
    ),
    RecipeIngredientItem(
      name: 'Chorizo',
      measureType: MeasureType.unit,
      quantity: 1,
    ),
  ];

  void setPrice(String value) {
    priceTouched = true;
    price = 0;
    priceError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Precio"),
      ValidatorsUtil.number(),
      ValidatorsUtil.positive(),
    ]);

    if (value == '') {
      price = null;
    } else {
      price = double.tryParse(value);
    }
    notifyListeners();
  }

  void setCost(String value) {
    costTouched = true;
    costError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Coste"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);
    if (value == '') {
      cost = null;
    } else {
      cost = double.tryParse(value);
    }
    notifyListeners();
  }

  void setStock(String value) {
    stockTouched = true;

    stockError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Stock"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);
    if (value == '') {
      stock = null;
    } else {
      stock = double.tryParse(value);
    }
    notifyListeners();
  }

  void setLowStock(String value) {
    lowStockTouched = true;
    if (value == '') {
      lowStock = null;
    } else {
      lowStock = double.tryParse(value);
    }
    lowStockError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Stock mínimo"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);

    notifyListeners();
  }

  void setRef(String value) {
    refTouched = true;

    refError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("REF"),
      ValidatorsUtil.alphanumeric(),
      ValidatorsUtil.minLength(3),
    ]);

    ref = refError == null ? value : null;

    notifyListeners();
  }

  void setCodeBar(String value) {
    codeBarTouched = true;

    codeBarError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Código"),
      ValidatorsUtil.alphanumeric(),
    ]);

    codeBar = codeBarError == null ? value : null;

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
      subcategories = await _service.getSubcategories(category.id);
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

      'ref': ValidatorsUtil.validate(ref, [
        ValidatorsUtil.required("REF"),
        ValidatorsUtil.alphanumeric(),
      ]),

      'codeBar': ValidatorsUtil.validate(codeBar, [
        ValidatorsUtil.required("Código"),
        ValidatorsUtil.alphanumeric(),
      ]),

      /// NUMÉRICOS
      'price': ValidatorsUtil.validate(normalize(price), [
        ValidatorsUtil.required("Precio"),
        ValidatorsUtil.number(),
        ValidatorsUtil.positive(),
      ]),

      'cost': ValidatorsUtil.validate(normalize(cost), [
        ValidatorsUtil.required("Coste"),
        ValidatorsUtil.number(),
        ValidatorsUtil.nonNegative(),
      ]),

      'stock': ValidatorsUtil.validate(normalize(stock), [
        ValidatorsUtil.required("Stock"),
        ValidatorsUtil.number(),
        ValidatorsUtil.nonNegative(),
      ]),

      'lowStock': ValidatorsUtil.validate(normalize(lowStock), [
        ValidatorsUtil.required("Stock mínimo"),
        ValidatorsUtil.number(),
        ValidatorsUtil.nonNegative(),
      ]),

      /// RELACIONES
      'category': selectedCategory == null ? "Selecciona una categoría" : null,

      'subcategory': selectedSubcategory == null
          ? "Selecciona una subcategoría"
          : null,

      'image': image == null ? "Imagen requerida" : null,
    };

    /// =========================
    /// 🔥 ASIGNAR A VARIABLES (CLAVE)
    /// =========================
    nameError = errors['name'];
    priceError = errors['price'];
    costError = errors['cost'];
    stockError = errors['stock'];
    lowStockError = errors['lowStock'];
    refError = errors['ref'];
    codeBarError = errors['codeBar'];
    categoryError = errors['category'];
    subcategoryError = errors['subcategory'];
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

    return isFormValid &&
        nameTouched &&
        priceTouched &&
        costTouched &&
        stockTouched &&
        lowStockTouched &&
        refTouched &&
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
      refError,
      codeBarError,
      categoryError,
      subcategoryError,
      imageError,
    ].every((e) => e == null);
  }

  MeasureType sellType = MeasureType.unit;
  TypeDesgloce sellTypeDesgloce = TypeDesgloce.menuRecipe;

  void setMeasureType(MeasureType type) {
    sellType = type;
    selectedUnitMeasure = null;
    notifyListeners();
  }

  InventoryType inventoryType = InventoryType.raw;


  void setInventoryType(InventoryType type) {
    inventoryType = type;
    notifyListeners();
  }

  void setDesgloce(TypeDesgloce type) {
    sellTypeDesgloce = type;
    notifyListeners();
  }

  void loadAndValidate(ProductDraft draft) {
    load(draft);
  }

  void load(ProductDraft draft) async {
    mode = CrudType.update;

    /// =========================
    /// 🧾 DATA
    /// =========================
    name = draft.name;
    price = draft.price;
    cost = draft.cost;
    stock = draft.stock;
    lowStock = draft.lowStock;

    ref = draft.code;
    codeBar = draft.barcode;

    if (draft.category.id > 0) {
      selectedCategory = categories.firstWhere(
        (c) => c.id == draft.category.id,
        orElse: () => ProductCategory.empty(),
      );
      subcategories = await _service.getSubcategories(selectedCategory!.id);
      if (draft.subcategory.id > 0) {
        selectedSubcategory = subcategories.firstWhere(
          (s) => s.id == draft.subcategory.id,
          orElse: () => ProductSubcategory.empty(),
        );
      }
    }

    image = draft.image;
    sellType = draft.sellType;

    /// =========================
    /// ⚠️ RESET TOUCH
    /// =========================
    nameTouched = false;
    priceTouched = false;
    costTouched = false;
    stockTouched = false;
    lowStockTouched = false;
    refTouched = false;
    codeBarTouched = false;
    imageTouched = false;
    categoryTouched = false;
    subcategoryTouched = false;

    /// =========================
    /// ❌ RESET ERRORES
    /// =========================
    nameError = null;
    priceError = null;
    costError = null;
    stockError = null;
    lowStockError = null;
    refError = null;
    codeBarError = null;
    categoryError = null;
    subcategoryError = null;
    imageError = null;

    validate();
    notifyListeners();
  }

  /// =========================
  /// 💾 SAVE
  /// =========================

  Future<ApiResponse<Map<String, dynamic>>> save(CrudType type) async {
    if (!validate().success) {
      throw Exception("Formulario inválido");
    }
    var payload = buildPayload();
    if(type==CrudType.create){
      final response = await ProductDataUtil.createProduct(payload);
      return response;
    }
    final response = await ProductDataUtil.updateProduct(payload);
    return response;
  }

  void _resetTouched() {
    nameTouched = false;
    priceTouched = false;
    costTouched = false;
    stockTouched = false;
    lowStockTouched = false;
    refTouched = false;
    codeBarTouched = false;
    imageTouched = false;
    categoryTouched = false;
    subcategoryTouched = false;
  }

  void _resetErrors() {
    nameError = null;
    priceError = null;
    costError = null;
    stockError = null;
    lowStockError = null;
    refError = null;
    codeBarError = null;
    categoryError = null;
    subcategoryError = null;
    imageError = null;
  }

  Map<String, dynamic> buildPayload() {
    switch (inventoryType) {
      case InventoryType.raw:
        return _buildRawPayload();
      case InventoryType.processed:
        return _buildProcessedPayload();

      case InventoryType.forSale:
        return _buildForSalePayload();
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
      'reference_type': 'INVENTARIO_INICIAL',
      'reference_id': null,
      'description': 'Carga inicial',
    };
  }

  void setListMeasureCategory(List<MeasureCategoryModel> list) {
    listMeasureCategoryData = list;
    notifyListeners();
  }

  Map<String, dynamic> _buildRawPayload() {
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
    return {
      'product': {
        'code': codeBar,
        'name': name,
        'product_type': 'MEASURABLE',
        'inventory_type': 'RAW',
        'state': 'ACTIVE',
        'product_trademark_id': 1,
        'product_category_id': selectedCategory?.id,
        'product_subcategory_id': selectedSubcategory?.id,
        'source': '',
        'description': ref,
        'code_provider': codeBar,
        'code_product': codeBar,
        'has_tax': hasTax?1:0,
        'is_service': 0,
        'user_id': user_id,
        'product_measure_type_id': product_measure_type_id,
        'view_online': 1,
      },
      'business_by_products': {'business_id': businessId},
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
        'sale_price4': price,
      },

      'product_sell_config': {
        'allow_pos': 1,
        'allow_shop': 1,
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
        'reference_type': measureData["reference_type"],
        'reference_id': measureData["reference_id"],
        'description': measureData["description"],
      },
    };
  }

  Map<String, dynamic> _buildProcessedPayload() {
    return {
      ..._buildRawPayload(),

      'recipe': {'name': name, 'yield_quantity': stock},

      'recipe_detail': ingredients
          .map(
            (e) => {
              'product_id': e.name, //ID TODO PRODUCT
              'quantity': e.quantity,
              'unit_measure_id': e.selectedUnit?.id,
            },
          )
          .toList(),
    };
  }

  Map<String, dynamic> _buildForSalePayload() {
    return {
      ..._buildRawPayload(),

      'recipe': {'name': name, 'yield_quantity': stock},

      'recipe_detail': ingredients
          .map(
            (e) => {
              'product_id': e.name, //ID TODO PRODUCT
              'quantity': e.quantity,
              'unit_measure_id': e.selectedUnit?.id,
            },
          )
          .toList(),
    };
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

    return ProductCategoryDraft(name: name, image: "");
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
