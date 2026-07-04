

import 'dart:async';
import 'dart:io';

import '../../../../../../../domain/services/session_service.dart';
import '../../../../../../../shared/models/api_response.dart';
import '../../../../../../../shared/utils/validators/validators.dart';
import '../../../../models/product_draft.dart';
import '../../../../services/pos_labels_service.dart';
import '../../../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../../molecules/ps_image_picker.dart';

class CategoryModalController extends BaseFormController {
  CrudType mode = CrudType.create;
  bool submitted = false;
  int categoryId = 0;
  final PosLabelsService labels = const PosLabelsService();
  final _eventModalProductController =
  StreamController<ManagementModalEvent>.broadcast();
  Stream<ManagementModalEvent> get eventsMainProcess =>
      _eventModalProductController.stream;

  void initField() {
    fields.addAll({
      'name': FormFieldController<String>(
        label: labels.categoryNameLabel,
        validators: [
          ValidatorsUtil.required(labels.categoryNameLabel),
          ValidatorsUtil.minLength(3),
        ],
      ),

      'description': FormFieldController<String>(
        label: labels.categoryDescriptionLabel,
        validators: [
          ValidatorsUtil.required(labels.categoryDescriptionLabel),
        ],
      ),

      'code': FormFieldController<String>(
        label: labels.categoryCodeLabel,
        validators: [
          ValidatorsUtil.required(labels.categoryCodeLabel),
          ValidatorsUtil.alphanumeric(),
        ],
      ),
    });
  }

  CategoryModalController() {
    initField();
  }

  void loadAndValidate(ProductCategoryDraft draft) {
    load(draft);
  }
  bool _allowActions = true;
  void resetProcess() {
    _allowActions = true;
    notifyListeners();
  }
  void load(ProductCategoryDraft draft) async {
    mode = CrudType.update;
    nameField.value = draft.name;
    descriptionField.value = draft.name;
    codeField.value = draft.name;
    categoryId = draft.id!;
    image = draft.image;
    nameField.touched = false;
    descriptionField.touched = false;
    codeField.touched = false;
    imageTouched = false;
    nameField.error = null;
    descriptionField.error = null;
    codeField.error = null;
    imageError = null;
    validate();
    notifyListeners();
  }
  void resetAllForm() {
    initField();
    resetValues();
    _resetTouched();
    _resetErrors();
  }
  void _resetErrors() {

    nameField.error = null;
    descriptionField.error = null;
    codeField.error = null;

    imageError = null;

  }
  void _resetTouched() {

    nameField.touched = false;
    descriptionField.touched = false;
    codeField.touched = false;

    imageTouched = false;

  }
  void resetValues() {
    image = null;

    nameField.value = null;
    descriptionField.value = null;
    codeField.value = null;

    categoryId = 0;
  }
  Future<void> init() async {

    notifyListeners();
  }
  FormFieldController<String> get nameField =>
      field<FormFieldController<String>>('name');

  FormFieldController<String> get descriptionField =>
      field<FormFieldController<String>>('description');

  FormFieldController<String> get codeField =>
      field<FormFieldController<String>>('code');
  String get name => nameField.value ?? '';

  String? get description => descriptionField.value;

  String? get code => codeField.value;

  String? get nameError => nameField.error;

  String? get descriptionError => descriptionField.error;

  String? get codeError => codeField.error;

  bool get nameTouched => nameField.touched;

  bool get descriptionTouched => descriptionField.touched;

  bool get codeTouched => codeField.touched;

  Map<String, dynamic> buildPayload(CrudType type) {

    final currentSession = SessionService().currentSession;

    final productCategory = {
      "name": name,
      "description": description,
      "code": code,
      "user_id": currentSession?.userId,
    };

    if(type == CrudType.update){
      productCategory["id"] = categoryId;
    }

    return {
      "product_category": productCategory
    };
  }
  Object? image;

  bool imageTouched = false;

  String? imageError;

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

  void setDescription(String value) {
    descriptionField.setValue(value);
    notifyListeners();
  }

  void setCode(String value) {
    codeField.setValue(value);
    notifyListeners();
  }
  ValidationResult validateForm() {
    submitted = true;

    super.validate();

    imageError = image == null
        ? "Imagen requerida"
        : null;

    final errors = {
      'name': nameError,
      'description': descriptionError,
      'code': codeError,
      'image': imageError,
    };

    final hasErrors = errors.values.any((e) => e != null);

    notifyListeners();

    return ValidationResult(
      success: !hasErrors,
      errors: errors,
      message: hasErrors
          ? "Formulario inválido"
          : "Formulario válido",
    );
  }
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  final _eventController = StreamController<ManagementModalEvent>.broadcast();

  void emit(String type, [dynamic data]) {
    _eventController.add(ManagementModalEvent(type, data));
  }
  bool get canSubmit {
    if (mode == CrudType.update) {
      return validateForm().success;
    }

    return isFormValid &&
        nameTouched &&
        descriptionTouched &&
        codeTouched &&
        imageTouched;
  }

  bool get isFormValid {
    return [
      nameError,
      descriptionError,
      codeError,
      imageError,
    ].every((e) => e == null);
  }
  bool allowReloadData = false;

  void setAllowReloadData(bool value) {
    allowReloadData = value;
    notifyListeners();
  }
  Future<ApiResponse<Map<String, dynamic>>> saveCategory(
      CrudType type) async {

    if (!validateForm().success) {
      throw Exception("Formulario inválido");
    }

    final imageManager = ImageMapper.map(image);

    final File? setImageCrud =
    imageManager.type == ImageSourceType.file
        ? imageManager.source as File
        : null;

    final payload = buildPayload(type);

    if (type == CrudType.create) {
      return CategoryDataUtil.createCategory(
        payload,
        image: setImageCrud,
      );
    }

    return CategoryDataUtil.updateCategory(
      payload,
      image: setImageCrud,
    );
  }
  String get nameLabel => labels.categoryNameLabel;

  String get descriptionLabel => labels.categoryDescriptionLabel;

  String get codeLabel => labels.categoryCodeLabel;

  String get imageLabel => labels.categoryImageLabel;

  String get titleCardInformation =>
      labels.categoryTitleCardInformation;

}


