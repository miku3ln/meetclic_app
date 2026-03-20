import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/sections/items/pos_items_management_section.dart';

import '../../../../shared/utils/validators/validators.dart';
import '../models/product_category.dart';
import '../models/product_draft.dart';
import '../models/product_subcategory.dart';
import '../services/product_catalog_service.dart';
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
  String? imageError;

  /// =========================
  /// 📂 CATEGORY
  /// =========================
  final _service = ProductCatalogService();

  List<ProductCategory> categories = [];
  List<ProductSubcategory> subcategories = [];

  ProductCategory? selectedCategory;
  ProductSubcategory? selectedSubcategory;

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

  void setPrice(String value) {
    priceTouched = true;
    price == null ? "" : double.tryParse(value);
    priceError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Precio"),
      ValidatorsUtil.number(),
      ValidatorsUtil.positive(),
    ]);

    notifyListeners();
  }

  void setCost(String value) {
    costTouched = true;
    cost == null ? "" : double.tryParse(value);

    costError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Coste"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);

    notifyListeners();
  }

  void setStock(String value) {
    stockTouched = true;

    stock == null ? "" : double.tryParse(value);

    stockError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Stock"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);

    notifyListeners();
  }

  void setLowStock(String value) {
    lowStockTouched = true;

    lowStock == null ? "" : double.tryParse(value);

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

  SellType sellType = SellType.unit;

  void setSellType(SellType type) {
    sellType = type;
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

  ProductDraft save(CrudType type) {
    if (!validate().success) {
      throw Exception("Formulario inválido");
    }

    return ProductDraft(
      name: name,
      price: price!,
      cost: cost!,
      category: selectedCategory!,
      subcategory: selectedSubcategory!,
      stock: stock!,
      lowStock: lowStock!,
      code: "",
      barcode: codeBar!,
      image: image!,
      sellType: sellType,
    );
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
}
