import 'dart:io';
import 'package:flutter/cupertino.dart';

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
  double? price;
  double? cost;
  double? stock;
  double? lowStock;

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
    price = double.tryParse(value);

    priceError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Precio"),
      ValidatorsUtil.number(),
      ValidatorsUtil.positive(),
    ]);

    notifyListeners();
  }

  void setCost(String value) {
    costTouched = true;
    cost = double.tryParse(value);

    costError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Coste"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);

    notifyListeners();
  }

  void setStock(String value) {
    stockTouched = true;
    stock = double.tryParse(value);

    stockError = ValidatorsUtil.validate(value, [
      ValidatorsUtil.required("Stock"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);

    notifyListeners();
  }

  void setLowStock(String value) {
    lowStockTouched = true;
    lowStock = double.tryParse(value);

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
  bool validate() {
    submitted = true;

    nameError = ValidatorsUtil.validate(name, [
      ValidatorsUtil.required("Nombre"),
    ]);

    priceError = ValidatorsUtil.validate(price?.toString(), [
      ValidatorsUtil.required("Precio"),
      ValidatorsUtil.number(),
      ValidatorsUtil.positive(),
    ]);

    costError = ValidatorsUtil.validate(cost?.toString(), [
      ValidatorsUtil.required("Coste"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);

    stockError = ValidatorsUtil.validate(stock?.toString(), [
      ValidatorsUtil.required("Stock"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);

    lowStockError = ValidatorsUtil.validate(lowStock?.toString(), [
      ValidatorsUtil.required("Stock mínimo"),
      ValidatorsUtil.number(),
      ValidatorsUtil.nonNegative(),
    ]);

    refError = ValidatorsUtil.validate(ref, [
      ValidatorsUtil.required("REF"),
      ValidatorsUtil.alphanumeric(),
    ]);

    codeBarError = ValidatorsUtil.validate(codeBar, [
      ValidatorsUtil.required("Código"),
      ValidatorsUtil.alphanumeric(),
    ]);

    categoryError =
    selectedCategory == null ? "Selecciona una categoría" : null;

    subcategoryError =
    selectedSubcategory == null ? "Selecciona una subcategoría" : null;

    imageError = image == null ? "Imagen requerida" : null;

    notifyListeners();

    return isFormValid;
  }

  /// =========================
  /// 🧠 FORM STATE
  /// =========================
  bool get canSubmit {
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

  /// =========================
  /// 💾 SAVE
  /// =========================

  ProductDraft save() {
    if (!validate()) {
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
}
