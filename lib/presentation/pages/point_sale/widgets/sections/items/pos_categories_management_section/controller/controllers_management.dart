

import 'dart:async';
import 'dart:io';

import '../../../../../../../../domain/services/session_service.dart';
import '../../../../../../../../shared/models/api_response.dart';
import '../../../../../../../../shared/utils/validators/validators.dart';
import '../../../../../services/pos_labels_service.dart';
import '../../../../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../../../molecules/ps_image_picker.dart';
import '../models/models_management.dart';
import '../repository/repository_management.dart';


class CategoryModalController extends BaseFormController {
  CrudType mode = CrudType.create;
  bool submitted = false;
  int categoryId = 0;
  final PosLabelsService labels = const PosLabelsService();
  final _eventController =
  StreamController<ManagementModalEvent>.broadcast();

  Stream<ManagementModalEvent> get eventsMainProcess =>
      _eventController.stream;

  void emit(String type, [dynamic data]) {
    _eventController.add(ManagementModalEvent(type, data));
  }
  void initField() {
    fields.addAll({
      'value': FormFieldController<String>(
        label: labels.categoryNameLabel,
        validators: [
          ValidatorsUtil.required(labels.categoryNameLabel),
          ValidatorsUtil.minLength(3),
        ],
      ),
      'subtitle': FormFieldController<String>(
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
    subtitleField.value = draft.name;

    descriptionField.value = draft.name;
    codeField.value = draft.name;
    categoryId = draft.id!;
    image = draft.image;
    nameField.touched = false;
    subtitleField.touched = false;
    descriptionField.touched = false;
    codeField.touched = false;
    imageTouched = false;
    nameField.error = null;
    subtitleField.error = null;
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
    subtitleField.error = null;

    descriptionField.error = null;
    codeField.error = null;

    imageError = null;

  }
  void _resetTouched() {
    nameField.touched = false;
    subtitleField.touched = false;
    descriptionField.touched = false;
    codeField.touched = false;
    imageTouched = false;
  }
  void resetValues() {
    image = null;
    nameField.value = null;
    subtitleField.value = null;
    descriptionField.value = null;
    codeField.value = null;
    categoryId = 0;
  }
  Future<void> init() async {
    notifyListeners();
  }
  FormFieldController<String> get nameField =>
      field<FormFieldController<String>>('value');
  FormFieldController<String> get subtitleField =>
      field<FormFieldController<String>>('subtitle');


  FormFieldController<String> get descriptionField =>
      field<FormFieldController<String>>('description');

  FormFieldController<String> get codeField =>
      field<FormFieldController<String>>('code');
  String get name => nameField.value ?? '';
  String get subtitle => subtitleField.value ?? '';



  String? get description => descriptionField.value;

  String? get code => codeField.value;

  String? get nameError => nameField.error;
  String? get subtitleError => subtitleField.error;

  String? get descriptionError => descriptionField.error;

  String? get codeError => codeField.error;

  bool get nameTouched => nameField.touched;
  bool get subtitleTouched => subtitleField.touched;

  bool get descriptionTouched => descriptionField.touched;

  bool get codeTouched => codeField.touched;

  Map<String, dynamic> buildPayload(CrudType type) {

    final currentSession = SessionService().currentSession;
    final businessId = SessionService().businessId;
    final productCategory = {
      "value": name,
      "subtitle": subtitle,
      "state": 'ACTIVE',
      "business_id": businessId,
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
  void setSubtitle(String value) {
   subtitleField.setValue(value);
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
      'value': nameError,
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

  bool get canSubmit {
    if (mode == CrudType.update) {
      return validateForm().success;
    }

    return isFormValid &&
        nameTouched &&
        subtitleTouched &&
        descriptionTouched &&
        codeTouched &&
        imageTouched;
  }

  bool get isFormValid {
    return [
      nameError,
      subtitleError,
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
      return CategoryListRepository.createCategory(
        payload,
        image: setImageCrud,
      );
    }

    return CategoryListRepository.updateCategory(
      payload,
      image: setImageCrud,
    );
  }
  String get nameLabel => labels.categoryNameLabel;
  String get subtitleLabel => labels.categorySubtitleLabel;

  String get descriptionLabel => labels.categoryDescriptionLabel;

  String get codeLabel => labels.categoryCodeLabel;

  String get imageLabel => labels.categoryImageLabel;

  String get titleCardInformation =>
      labels.categoryTitleCardInformation;


  CrudType typeManagementRegister = CrudType.create;
  int idManagementRow = -1;
  String titleManagement = "";

  void setManagerInitProcess(CrudType typeManagement, int managementId) {
    typeManagementRegister = typeManagement;
    idManagementRow = managementId;
    if (typeManagement == CrudType.create) {
      titleManagement = "Crear Categoria";
    } else {
      titleManagement = "Actualizar Categoria";
    }
    notifyListeners();
  }
}


