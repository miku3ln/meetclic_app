import 'dart:async';
import 'dart:io';

import '../../../../../../../../domain/services/session_service.dart';
import '../../../../../../../../shared/models/api_response.dart';
import '../../../../../../../../shared/pagination_response.dart';
import '../../../../../../../../shared/utils/validators/validators.dart';
import '../../../../../services/pos_labels_service.dart';
import '../../../../molecules/ps_image_picker.dart';
import '../models/models_management.dart';
import '../repository/repository_management.dart';

class CategoryModalController extends BaseFormController {
  CrudType mode = CrudType.create;
  bool submitted = false;
  int categoryId = 0;
  bool allowReloadData = false;
  Object? image;
  bool imageTouched = false;
  String? imageError;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool _allowActions = true;

  final PosLabelsService labels = const PosLabelsService();
  final _eventController = StreamController<ManagementModalEvent>.broadcast();

  Stream<ManagementModalEvent> get eventsMainProcess => _eventController.stream;

  void emit(String type, [dynamic data]) {
    _eventController.add(ManagementModalEvent(type, data));
  }

  void initFields() {
    fields.clear();
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
        validators: [ValidatorsUtil.required(labels.categoryDescriptionLabel)],
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
    initFields();
  }

  void loadAndValidate(ProductCategoryDraft draft) {
    load(draft);
  }

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
    validate();
    notifyListeners();
  }

  void resetAllForm() {
    initFields();
    _resetValuesManagement();
  }

  void _resetValuesManagement() {
    resetForm();
    image = null;
    categoryId = 0;
  }

  Future<void> init() async {
    resetAllForm();
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

  String get nameLabel => labels.categoryNameLabel;

  String get subtitleLabel => labels.categorySubtitleLabel;

  String get descriptionLabel => labels.categoryDescriptionLabel;

  String get codeLabel => labels.categoryCodeLabel;

  String get imageLabel => labels.categoryImageLabel;

  String get titleCardInformation => labels.categoryTitleCardInformation;
  CrudType typeManagementRegister = CrudType.create;
  int idManagementRow = -1;
  String titleManagement = "";
  String get imageLabelRequired =>"Imagen requerida";
  String get formLabelValid =>"Formulario inválido";
  String get formLabelInValid =>"Formulario válido";
  String get titleMainCreate =>  "Crear Categoria";
  String get titleMainUpdate =>  "Actualizar Categoria";
  String get titleEmptyRegisters =>  "Todavía no hay Categorias.!";
  String get titleEmptyDescription =>  "Aquí puedes verificar";
  String get titleEmptyLinkText =>  "Más información";
  String get btnSaveText =>  "Guardar";
  String get btnUpdateText =>  "Actualizar";

  String get btnCancelText =>  "Cancelar";


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

    if (type == CrudType.update) {
      productCategory["id"] = categoryId;
    }

    return {"product_category": productCategory};
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
    imageError = imageLabelRequired;
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
    final resultFields = validateFields();
    imageError = image == null ? imageLabelRequired : null;
    final errors = {
      ...resultFields.errors,
      'image': imageError,
    };

    final hasErrors = errors.values.any((e) => e != null);
    notifyListeners();
    return ValidationResult(
      success: !hasErrors,
      errors: errors,
      message: hasErrors ? formLabelInValid : formLabelValid,
    );
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get canSubmit {
    if (mode == CrudType.update) {
      return isValid && imageError == null;
    }

    return isValid &&
        areAllFieldsTouched &&
        imageTouched;
  }

  bool get isFormValid  =>
      isValid && imageError == null;

  void setAllowReloadData(bool value) {
    allowReloadData = value;
    notifyListeners();
  }

  Future<ApiResponse<Map<String, dynamic>>> saveRegister(CrudType type) async {
    if (!validateForm().success) {
      throw Exception(formLabelInValid);
    }
    final imageManager = ImageMapper.map(image);
    final File? setImageCrud = imageManager.type == ImageSourceType.file
        ? imageManager.source as File
        : null;
    final payload = buildPayload(type);
    if (type == CrudType.create) {
      return CategoryListRepository.createCategory(
        payload,
        image: setImageCrud,
      );
    }
    return CategoryListRepository.updateCategory(payload, image: setImageCrud);
  }

  void setManagerInitProcess(CrudType typeManagement, int managementId) {
    typeManagementRegister = typeManagement;
    idManagementRow = managementId;
    if (typeManagement == CrudType.create) {
      titleManagement = titleMainCreate;
    } else {
      titleManagement =titleMainUpdate;
    }
    notifyListeners();
  }
}
class CategoryListController {
  CategoryListController({
    required this.repository,
    this.rowCount = 10,
  });

  CategoryListRepository repository;

  final int rowCount;

  int simulatedTotal = 0;

  final List<GenericListItem<Map<String, dynamic>>> items = [];

  int currentPage = 1;

  String searchCode = '';

  int total = 0;

  bool isLoading = false;

  bool hasInitialLoadFinished = false;

  bool get hasData => items.isNotEmpty;

  bool get hasMore => items.length < total;

  Future<void> loadInitial() async {
    if (isLoading) return;

    isLoading = true;

    final response = await repository.fetchPage(
      current: currentPage,
      rowCount: rowCount,
      searchPhrase: searchCode,
    );

    simulatedTotal = response.total;

    items.addAll(response.rows);

    total = response.total;

    hasInitialLoadFinished = true;

    isLoading = false;
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    currentPage++;

    final response = await repository.fetchPage(
      current: currentPage,
      rowCount: rowCount,
      searchPhrase: searchCode,
    );

    items.addAll(response.rows);

    total = response.total;

    isLoading = false;
  }

  Future<void> resetAll() async {
    if (isLoading) return;

    repository = CategoryListRepository(
      total: simulatedTotal,
    );

    currentPage = 1;

    items.clear();

    total = 0;

    hasInitialLoadFinished = false;

    await loadInitial();
  }

  Future<void> search(String value) async {
    searchCode = value;
    await resetAll();
  }
}