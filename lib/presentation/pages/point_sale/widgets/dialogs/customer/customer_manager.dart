import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../shared/utils/validators/validators.dart';
import '../../../repositories/config_repository.dart';
import '../../../state/product_modal_controller.dart';
import '../../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import '../../molecules/inputs/ps_input.dart';
import '../../sections/product/ps_section_card.dart';
import '../moda_managerl.dart';

class PosCustomerFormData {
  // ==========================================
  // CUSTOMER
  // ==========================================

  int id;
  String identificationDocument;
  int peopleTypeIdentificationId;
  int peopleId;
  String businessName;
  String businessReason;
  int? rucTypeId;

  // ==========================================
  // CUSTOMER INFORMATION
  // ==========================================

  int customerId;
  int customerByInformationId;
  int? peopleNationalityId;
  int? peopleProfessionId;

  // ==========================================
  // PEOPLE
  // ==========================================

  String lastName;
  String name;
  String birthdate;
  int gender;
  int businessId;
  int age;

  // ==========================================
  // PHONE
  // ==========================================

  int informationPhoneId;
  String informationPhoneValue;
  int? informationPhoneOperatorId;
  int? informationPhoneTypeId;

  PosCustomerFormData({
    this.id = -1,
    this.identificationDocument = '',
    this.peopleTypeIdentificationId =
        PosCustomerDefaults.identificationTypeId,
    this.peopleId = -1,
    this.businessName = '',
    this.businessReason = '',
    this.rucTypeId = PosCustomerDefaults.rucTypeId,
    this.customerId = -1,
    this.customerByInformationId = -1,
    this.peopleNationalityId =
        PosCustomerDefaults.nationalityId,
    this.peopleProfessionId =
        PosCustomerDefaults.professionId,
    this.lastName = '',
    this.name = '',
    this.birthdate = '',
    this.gender = PosCustomerDefaults.gender,
    this.businessId = -1,
    this.age = PosCustomerDefaults.age,
    this.informationPhoneId = -1,
    this.informationPhoneValue = '',
    this.informationPhoneOperatorId =
        PosCustomerDefaults.phoneOperatorId,
    this.informationPhoneTypeId =
        PosCustomerDefaults.phoneTypeId,
  });

  // ==========================================
  // HELPERS
  // ==========================================

  static int parseInt(dynamic value, [int fallback = -1]) {
    if (value == null) return fallback;

    if (value is Map) {
      return parseInt(value['id'], fallback);
    }

    return int.tryParse(value.toString()) ?? fallback;
  }

  static int? parseNullableInt(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      return parseNullableInt(value['id']);
    }

    return int.tryParse(value.toString());
  }

  static String parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  // ==========================================
  // FROM JSON - UPDATE
  // ==========================================

  factory PosCustomerFormData.fromJson(
      Map<String, dynamic> json, {
        int fallbackBusinessId = -1,
      }) {
    final data = json['Customer'] is Map
        ? Map<String, dynamic>.from(json['Customer'])
        : json;

    return PosCustomerFormData(
      id: parseInt(data['id']),
      identificationDocument:
      parseString(data['identification_document']),
      peopleTypeIdentificationId: parseInt(
        data['people_type_identification_id'],
        PosCustomerDefaults.identificationTypeId,
      ),
      peopleId: parseInt(data['people_id']),
      businessName: parseString(data['business_name']),
      businessReason: parseString(data['business_reason']),
      rucTypeId: parseNullableInt(data['ruc_type_id']),
      customerId: parseInt(
        data['customer_id'] ?? data['id'],
      ),
      customerByInformationId: parseInt(
        data['customer_by_information_id'],
      ),
      peopleNationalityId: parseNullableInt(
        data['people_nationality_id'],
      ),
      peopleProfessionId: parseNullableInt(
        data['people_profession_id'],
      ),
      lastName: parseString(data['last_name']),
      name: parseString(data['name']),
      birthdate: parseString(data['birthdate']),
      gender: parseInt(
        data['gender'],
        PosCustomerDefaults.gender,
      ),
      businessId: parseInt(
        data['business_id'],
        fallbackBusinessId,
      ),
      age: parseInt(data['age'], 0),
      informationPhoneId: parseInt(
        data['information_phone_id'],
      ),
      informationPhoneValue: parseString(
        data['information_phone_value'],
      ),
      informationPhoneOperatorId: parseNullableInt(
        data['information_phone_operator_id'],
      ),
      informationPhoneTypeId: parseNullableInt(
        data['information_phone_type_id'],
      ),
    );
  }

  // ==========================================
  // TO JSON - LARAVEL
  // ==========================================

  Map<String, dynamic> toJson() {
    final customerData = <String, dynamic>{
      // CUSTOMER
      'id': id,
      'identification_document':
      identificationDocument.trim(),
      'people_type_identification_id':
      peopleTypeIdentificationId,
      'people_id': peopleId,
      'business_name': businessName,
      'business_reason': businessReason,
      'ruc_type_id': rucTypeId,

      // CUSTOMER INFORMATION
      'customer_id': customerId,
      'people_nationality_id': peopleNationalityId,
      'people_profession_id': peopleProfessionId,
      'customer_by_information_id':
      customerByInformationId,

      // PEOPLE
      'last_name': lastName.trim(),
      'name': name.trim(),
      'birthdate': birthdate,
      'gender': gender,
      'business_id': businessId,
      'age': age,
    };

    // PHONE
    if (informationPhoneValue.trim().isNotEmpty) {
      customerData.addAll({
        'information_phone_id': informationPhoneId,
        'information_phone_value':
        informationPhoneValue.trim(),
        'information_phone_operator_id': {
          'id': informationPhoneOperatorId,
        },
        'information_phone_type_id': {
          'id': informationPhoneTypeId,
        },
      });
    }

    return {
      'Customer': customerData,
    };
  }
}
class PosCustomerDefaults {
  // ==========================================
  // IDENTIFIERS
  // ==========================================

  static const int newRecordId = -1;

  // ==========================================
  // CUSTOMER
  // ==========================================

  // Confirmar que 3 corresponde al tipo
  // de identificación deseado en tu catálogo.
  static const int identificationTypeId = 3;

  static const int? rucTypeId = 1;

  // ==========================================
  // CUSTOMER INFORMATION
  // ==========================================

  static const int? nationalityId = 1;
  static const int? professionId = 1;

  // ==========================================
  // PEOPLE
  // ==========================================

  static const int gender = 0;
  static const int age = 0;

  // ==========================================
  // PHONE
  // ==========================================

  static const int? phoneTypeId = 1;
  static const int? phoneOperatorId = 1;
}
class CustomerModalController extends ChangeNotifier {

  // ==========================================
  // VIEW STATE
  // ==========================================

  CustomerViewType view = CustomerViewType.list;

  // ==========================================
  // DATA
  // ==========================================

  List<CustomerModelPosCurrent> customers = [];

  CustomerModelPosCurrent? selectedCustomer;

  // ==========================================
  // SEARCH
  // ==========================================

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
        .where(
          (c) => c.name.toLowerCase().contains(
        search.toLowerCase(),
      ),
    )
        .toList();
  }

  bool initialized = false;

  // ==========================================
  // FORM DATA - CAMPOS VISIBLES
  // ==========================================

  String identificationDocument = "";

  String lastName = "";

  String name = "";

  String birthdate = "";

  int gender = 0;

  String informationPhoneValue = "";

  // ==========================================
  // FORM DATA - CAMPOS EXISTENTES
  // Se conservan para otros widgets
  // ==========================================

  String email = "";

  String phone = "";

  String city = "";

  // ==========================================
  // CUSTOMER - CAMPOS OCULTOS
  // ==========================================

  int id = -1;

  int peopleTypeIdentificationId = 3;

  int peopleId = -1;

  String businessName = "";

  String businessReason = "";

  int rucTypeId=1;

  // ==========================================
  // CUSTOMER INFORMATION
  // ==========================================

  int customerId = -1;

  int customerByInformationId = -1;

  int peopleNationalityId=1;

  int peopleProfessionId=1;

  // ==========================================
  // PEOPLE
  // ==========================================

  int businessId = 1;

  int age = 0;

  // ==========================================
  // PHONE
  // ==========================================

  int informationPhoneId = -1;

  int informationPhoneOperatorId=1;

  int informationPhoneTypeId=1;

  // ==========================================
  // TOUCHED
  // ==========================================

  bool identificationTouched = false;

  bool lastNameTouched = false;

  bool nameTouched = false;

  bool birthdateTouched = false;

  bool phoneTouched = false;

  // ==========================================
  // ERRORS
  // ==========================================

  String? identificationError;

  String? lastNameError;

  String? nameError;

  String? birthdateError;

  String? phoneError;
  bool emailTouched = false;
  String? emailError;
  String? _validateEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }

    final regex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!regex.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido.';
    }

    return null;
  }
  void setEmail(String val) {
    email = val.trim();

    emailTouched = true;
    emailError = _validateEmail(email);

    notifyListeners();
  }
  // ==========================================
  // SETTERS - IDENTIFICATION
  // ==========================================

  void setIdentificationDocument(String val) {
    identificationDocument = val;

    identificationTouched = true;

    identificationError = ValidatorsUtil.validate(
      val.trim(),
      [
        ValidatorsUtil.required("Identificación"),
        ValidatorsUtil.minLength(3),
      ],
    );

    notifyListeners();
  }

  // ==========================================
  // SETTERS - NAME
  // ==========================================

  void setName(String val) {
    name = val;

    nameTouched = true;

    nameError = ValidatorsUtil.validate(
      val.trim(),
      [
        ValidatorsUtil.required("Nombre"),
        ValidatorsUtil.minLength(3),
      ],
    );

    notifyListeners();
  }

  // ==========================================
  // SETTERS - LAST NAME
  // ==========================================

  void setLastName(String val) {
    lastName = val;

    lastNameTouched = true;

    lastNameError = ValidatorsUtil.validate(
      val.trim(),
      [
        ValidatorsUtil.required("Apellido"),
        ValidatorsUtil.minLength(3),
      ],
    );

    notifyListeners();
  }

  // ==========================================
  // SETTERS - BIRTHDATE
  // ==========================================

  void setBirthdate(String val) {
    birthdate = val;

    birthdateTouched = true;

    birthdateError = _validateBirthdate(val);

    notifyListeners();
  }

  // ==========================================
  // SETTERS - GENDER
  // ==========================================

  void setGender(int val) {
    gender = val;

    notifyListeners();
  }

  // ==========================================
  // SETTERS - PHONE
  // ==========================================

  void setInformationPhoneValue(String val) {
    informationPhoneValue = val;

    // Mantener compatibilidad con phone
    phone = val;

    phoneTouched = true;

    phoneError = _validatePhone(val);

    notifyListeners();
  }

  // ==========================================
  // SETTERS EXISTENTES
  // ==========================================



  void setPhone(String val) {
    phone = val;

    informationPhoneValue = val;

    phoneTouched = true;

    phoneError = _validatePhone(val);

    notifyListeners();
  }

  void setCity(String val) {
    city = val;

    notifyListeners();
  }

  // ==========================================
  // VALIDATE BIRTHDATE
  // ==========================================

  String? _validateBirthdate(String val) {
    if (val.trim().isEmpty) {
      return "La fecha de nacimiento es obligatoria.";
    }

    final regex = RegExp(
      r'^\d{4}-\d{2}-\d{2}$',
    );

    if (!regex.hasMatch(val)) {
      return "Formato requerido AAAA-MM-DD.";
    }

    final date = DateTime.tryParse(val);

    if (date == null) {
      return "Fecha inválida.";
    }

    final normalized =
        "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    if (normalized != val) {
      return "Fecha inválida.";
    }

    if (date.isAfter(DateTime.now())) {
      return "La fecha no puede ser futura.";
    }

    return null;
  }

  // ==========================================
  // VALIDATE PHONE
  // ==========================================
  String? _validatePhone(String val) {
    final phone = val.trim().replaceAll(RegExp(r'[\s-]'), '');

    if (phone.isEmpty) {
      return 'El celular es obligatorio.';
    }

    // Formatos aceptados:
    // 0985339457
    // 593985339457
    // +593985339457
    final regex = RegExp(r'^(09\d{8}|5939\d{8}|\+5939\d{8})$');

    if (!regex.hasMatch(phone)) {
      return 'Ingresa un celular ecuatoriano válido.';
    }

    return null;
  }
  String normalizeEcuadorPhone(String value) {
    final phone = value.trim().replaceAll(RegExp(r'[\s-]'), '');

    if (phone.startsWith('+593')) {
      return phone.substring(1);
    }

    if (phone.startsWith('09')) {
      return '593${phone.substring(1)}';
    }

    return phone;
  }
  // ==========================================
  // VALIDATION
  // ==========================================
  bool get isFormValid {
    final isCreate = view == CustomerViewType.create;
    final isUpdate = view == CustomerViewType.update;

    if (!isCreate && !isUpdate) return false;

    final personalDataValid =
        identificationDocument.trim().length >= 3 &&
            name.trim().length >= 3 &&
            lastName.trim().length >= 3 &&
            _validateBirthdate(birthdate) == null &&
            _validatePhone(informationPhoneValue) == null;

    final emailValid = isCreate
        ? _validateEmail(email) == null
        : email.trim().isEmpty || _validateEmail(email) == null;

    return personalDataValid && emailValid;
  }
  bool get canSubmit {
    final isCreate = view == CustomerViewType.create;
    final isUpdate = view == CustomerViewType.update;

    if (!isCreate && !isUpdate) return false;

    if (isSaving) return false;

    if (!isFormValid) return false;

    // UPDATE necesita los identificadores originales.
    if (isUpdate) {
      return id > 0 &&
          customerId > 0 &&
          peopleId > 0;
    }

    return true;
  }

  ValidationResult validate() {
    identificationTouched = true;
    nameTouched = true;
    lastNameTouched = true;
    birthdateTouched = true;
    phoneTouched = true;
    emailTouched = true;
    identificationError = ValidatorsUtil.validate(
      identificationDocument.trim(),
      [
        ValidatorsUtil.required("Identificación"),
        ValidatorsUtil.minLength(3),
      ],
    );

    nameError = ValidatorsUtil.validate(
      name.trim(),
      [
        ValidatorsUtil.required("Nombre"),
        ValidatorsUtil.minLength(3),
      ],
    );

    lastNameError = ValidatorsUtil.validate(
      lastName.trim(),
      [
        ValidatorsUtil.required("Apellido"),
        ValidatorsUtil.minLength(3),
      ],
    );

    birthdateError = _validateBirthdate(birthdate);

    phoneError = _validatePhone(informationPhoneValue);
    emailError = view == CustomerViewType.update &&
        email.trim().isEmpty
        ? null
        : _validateEmail(email);
    notifyListeners();

    final success =emailError == null &&
        identificationError == null &&
            nameError == null &&
            lastNameError == null &&
            birthdateError == null &&
            phoneError == null;

    return ValidationResult(
      success: success,
      errors: {
        'email': emailError,
        'identification_document': identificationError,
        'name': nameError,
        'last_name': lastNameError,
        'birthdate': birthdateError,
        'information_phone_value': phoneError,
      },
      message: success
          ? "OK"
          : "Formulario inválido",
    );
  }

  // ==========================================
  // NAVIGATION
  // ==========================================

  void goToCreate() {
    _resetForm();

    mode = CrudType.create;

    view = CustomerViewType.create;

    notifyListeners();
  }

  void goToDetail(CustomerModelPosCurrent c) {
    selectedCustomer = c;
    view = CustomerViewType.detail;
    notifyListeners();
  }

  void back() {
    if (openedWithCustomer &&
        view == CustomerViewType.detail) {
      openedWithCustomer = false;
      view = CustomerViewType.list;
      notifyListeners();
      return;
    }

    if (
    view == CustomerViewType.detail ||
        view == CustomerViewType.create ||
        view == CustomerViewType.update
    ) {
      view = CustomerViewType.list;
    }

    notifyListeners();
  }

  // ==========================================
  // SAVE STATE
  // ==========================================

  bool isSaving = false;
  Future<void> _selectBirthdate(
      BuildContext context,
      CustomerModalController controller,
      ) async {
    final now = DateTime.now();

    final currentDate = DateTime.tryParse(controller.birthdate);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Selecciona la fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      locale: const Locale('es', 'EC'),
    );

    if (selectedDate == null) return;

    final formattedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    controller.setBirthdate(formattedDate);
  }
  String? saveErrorMessage;

  // ==========================================
  // GET VALUES SAVE
  // Equivalente al JavaScript
  // ==========================================

  Map<String, dynamic> getValuesSave() {
    final customerData = <String, dynamic>{

      // CUSTOMER
      'id': id,
      'email': email.trim(),
      'identification_document':
      identificationDocument.trim(),

      'people_type_identification_id':
      peopleTypeIdentificationId,

      'people_id': peopleId,

      'business_name': businessName,

      'business_reason': businessReason,

      'ruc_type_id': rucTypeId,

      // CUSTOMER INFORMATION
      'customer_id': customerId,

      'people_nationality_id':
      peopleNationalityId,

      'people_profession_id':
      peopleProfessionId,

      // PEOPLE
      'last_name': lastName.trim(),

      'name': name.trim(),

      'birthdate': birthdate,

      'gender': gender,

      'business_id': businessId,

      'age': age,

      'customer_by_information_id':
      customerByInformationId,
    };

    // ==========================================
    // PHONE
    // ==========================================

    if (informationPhoneValue.trim().isNotEmpty) {
      customerData['information_phone_id'] =
          informationPhoneId;

      customerData['information_phone_value'] =
          normalizeEcuadorPhone(informationPhoneValue);

      customerData['information_phone_operator_id'] = {
        'id': informationPhoneOperatorId,
      };

      customerData['information_phone_type_id'] = {
        'id': informationPhoneTypeId,
      };
    }

    return {
      'Customer': customerData,
    };
  }

  // ==========================================
  // SAVE
  // ==========================================

  Future<bool> save() async {
    if (isSaving) return false;

    final validation = validate();

    if (!validation.success) {
      return false;
    }
    if (
    view == CustomerViewType.update &&
        (customerId <= 0 || peopleId <= 0)
    ) {
      saveErrorMessage =
      "No se encontraron los identificadores "
          "necesarios para actualizar el cliente.";

      notifyListeners();
      return false;
    }

    isSaving = true;
    saveErrorMessage = null;

    notifyListeners();

    try {
      final body = getValuesSave();

      final result = await CustomerManagerService.saveCustomer(
        body,
      );

      if (result['success'] != true) {
        final errors = result['errors'];

        final errorDetails = errors is List
            ? errors
            .map((error) => error.toString())
            .join('\n')
            : '';

        final step = result['step'];
        final operation = result['operation'];

        saveErrorMessage = [
          result['message']?.toString() ??
              "No se pudo guardar el cliente.",
          if (errorDetails.isNotEmpty) errorDetails,
          if (step != null) "STEP: $step",
          if (operation != null)
            "Operación: $operation",
        ].join('\n');

        return false;
      }

      view = CustomerViewType.list;

      return true;
    } catch (_) {
      saveErrorMessage =
      "Ocurrió un error al guardar el cliente.";

      return false;
    } finally {
      isSaving = false;

      notifyListeners();
    }
  }

  // ==========================================
  // RESET
  // ==========================================

  void reset() {
    view = CustomerViewType.list;

    selectedCustomer = null;

    customerInTicket = null;

    detailTab = CustomerDetailTab.profile;

    initialized = false;

    _resetForm();

    notifyListeners();
  }

  // ==========================================
  // RESET FORM
  // ==========================================

  void _resetForm() {
    // CUSTOMER
    id = -1;
    identificationDocument = "";
    peopleTypeIdentificationId = 3;
    peopleId = -1;
    businessName = "";
    businessReason = "";
    rucTypeId = 1;

    // CUSTOMER INFORMATION
    customerId = -1;
    customerByInformationId = -1;
    peopleNationalityId = 1;
    peopleProfessionId = 1;

    // PEOPLE
    lastName = "";
    name = "";
    birthdate = "";
    gender = 0;
    age = 0;

    // PHONE
    informationPhoneId = -1;
    informationPhoneValue = "";
    informationPhoneOperatorId = 1;
    informationPhoneTypeId = 1;

    // EXISTING
    email = "";
    phone = "";
    city = "";

    // VALIDATION
    identificationTouched = false;
    lastNameTouched = false;
    nameTouched = false;
    birthdateTouched = false;
    phoneTouched = false;

    identificationError = null;
    lastNameError = null;
    nameError = null;
    birthdateError = null;
    phoneError = null;

    saveErrorMessage = null;

    // businessId no se reinicia:
    // pertenece al contexto del POS.
  }

  // ==========================================
  // TICKET
  // ==========================================

  bool isSelectedInTicket = false;

  CustomerModelPosCurrent? customerInTicket;

  bool isCustomerSelected(CustomerModelPosCurrent c) {
    return customerInTicket?.id == c.id;
  }

  void toggleCustomerInTicket() {
    if (selectedCustomer == null) return;

    if (customerInTicket?.id == selectedCustomer!.id) {
      customerInTicket = null;
    } else {
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

    openedWithCustomer = true;

    view = CustomerViewType.detail;

    notifyListeners();
  }

  CustomerDetailTab detailTab =
      CustomerDetailTab.profile;

  void setDetailTab(CustomerDetailTab tab) {
    detailTab = tab;

    notifyListeners();
  }

  CrudType mode = CrudType.create;

  // ==========================================
  // EDIT
  // ==========================================

  void goToEdit() {
    // ==========================================
    // 1. VALIDATE CUSTOMER
    // ==========================================

    final customer = selectedCustomer;

    if (customer == null || isSaving) {
      return;
    }

    // ==========================================
    // 2. LOAD CUSTOMER FOR UPDATE
    // ==========================================

    loadCustomerForUpdate(
      customer.toEditMap(),
    );
  }
  // ==========================================
  // LOAD FULL CUSTOMER FOR UPDATE
  // ==========================================

  void loadCustomerForUpdate(
      Map<String, dynamic> data,
      ) {
    // ==========================================
    // 1. RESET FORM
    // ==========================================

    if (isSaving) return;

    // Conservar el businessId del POS antes del reset.
    final currentBusinessId = businessId;

    _resetForm();

    businessId = currentBusinessId;

    // ==========================================
    // 2. HELPERS
    // ==========================================

    int parseId(dynamic value, [int fallback = -1]) {
      if (value == null) return fallback;

      if (value is Map) {
        return parseId(value['id'], fallback);
      }

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(value.toString().trim()) ?? fallback;
    }

    String parseString(dynamic value) {
      return value?.toString().trim() ?? '';
    }

    // ==========================================
    // 3. CUSTOMER IDENTIFIERS
    // ==========================================

    // ID principal recibido desde Laravel.
    id = parseId(data['id']);

    // ID real del cliente.
    // No se debe asumir que es igual a id.
    customerId = parseId(
      data['customer_id'],
    );

    // ID de la persona.
    peopleId = parseId(
      data['people_id'],
    );

    // ID de la relación de información del cliente.
    customerByInformationId = parseId(
      data['customer_by_information_id'],
    );

    // ==========================================
    // 4. CUSTOMER INFORMATION
    // ==========================================

    identificationDocument = parseString(
      data['identification_document'],
    );

    peopleTypeIdentificationId = parseId(
      data['people_type_identification_id'],
      3,
    );

    businessName = parseString(
      data['business_name'],
    );

    businessReason = parseString(
      data['business_reason'],
    );

    rucTypeId = parseId(
      data['ruc_type_id'],
      1,
    );

    // ==========================================
    // 5. NATIONALITY / PROFESSION
    // ==========================================

    peopleNationalityId = parseId(
      data['people_nationality_id'],
      1,
    );

    peopleProfessionId = parseId(
      data['people_profession_id'],
      1,
    );

    // ==========================================
    // 6. PERSONAL INFORMATION
    // ==========================================

    name = parseString(
      data['name'],
    );

    lastName = parseString(
      data['last_name'],
    );

    gender = parseId(
      data['gender'],
      0,
    );

    age = parseId(
      data['age'],
      0,
    );

    // ==========================================
    // 7. BUSINESS ID
    // ==========================================

    businessId = parseId(
      data['business_id'],
      currentBusinessId,
    );

    // ==========================================
    // 8. BIRTHDATE
    // ==========================================

    final rawBirthdate = parseString(
      data['birthdate'],
    );

    final parsedBirthdate = DateTime.tryParse(
      rawBirthdate,
    );

    if (parsedBirthdate != null) {
      birthdate =
      '${parsedBirthdate.year.toString().padLeft(4, '0')}-'
          '${parsedBirthdate.month.toString().padLeft(2, '0')}-'
          '${parsedBirthdate.day.toString().padLeft(2, '0')}';
    } else {
      birthdate = rawBirthdate;
    }

    // ==========================================
    // 9. PHONE INFORMATION
    // ==========================================

    informationPhoneId = parseId(
      data['information_phone_id'],
    );

    informationPhoneValue = parseString(
      data['information_phone_value'],
    );

    informationPhoneOperatorId = parseId(
      data['information_phone_operator_id'],
      1,
    );

    informationPhoneTypeId = parseId(
      data['information_phone_type_id'],
      1,
    );

    // Mantener compatibilidad con otros widgets.
    phone = informationPhoneValue;

    // ==========================================
    // 10. ADDITIONAL INFORMATION
    // ==========================================

    email = parseString(
      data['email'],
    );

    city = parseString(
      data['city'],
    );

    // ==========================================
    // 11. RESET VALIDATION STATE
    // ==========================================

    identificationTouched = false;
    nameTouched = false;
    lastNameTouched = false;
    birthdateTouched = false;
    phoneTouched = false;
    emailTouched = false;

    identificationError = null;
    nameError = null;
    lastNameError = null;
    birthdateError = null;
    phoneError = null;
    emailError = null;

    saveErrorMessage = null;

    // ==========================================
    // 12. UPDATE MODE
    // ==========================================

    mode = CrudType.update;
    view = CustomerViewType.update;

    // ==========================================
    // 13. DEBUG IDENTIFIERS
    // ==========================================

    debugPrint('========================================');
    debugPrint('CUSTOMER UPDATE - DATA LOADED');
    debugPrint('========================================');

    debugPrint('ID: $id');
    debugPrint('CUSTOMER ID: $customerId');
    debugPrint('PEOPLE ID: $peopleId');

    debugPrint(
      'CUSTOMER BY INFORMATION ID: '
          '$customerByInformationId',
    );

    debugPrint(
      'INFORMATION PHONE ID: $informationPhoneId',
    );

    debugPrint('BUSINESS ID: $businessId');

    debugPrint('----------------------------------------');

    debugPrint('FORM VALID: $isFormValid');
    debugPrint('CAN SUBMIT: $canSubmit');

    debugPrint('========================================');

    // ==========================================
    // 14. UPDATE UI
    // ==========================================

    notifyListeners();
  }

  // ==========================================
  // SERVICE
  // ==========================================

  final CustomerServiceModal _service;

  CustomerModalController(this._service);

  bool isLoading = false;

  String? errorMessage;


}

class CustomerCreateView extends StatelessWidget {
  final CustomerModalController controller;

  const CustomerCreateView(
      this.controller, {
        super.key,
      });

  // ==========================================
  // DATE PICKER - FECHA DE NACIMIENTO
  // ==========================================

  Future<void> _selectBirthdate(
      BuildContext context,
      ) async {
    if (controller.isSaving) return;

    final now = DateTime.now();

    final currentDate = DateTime.tryParse(
      controller.birthdate,
    );

    final initialDate = currentDate != null &&
        !currentDate.isAfter(now) &&
        !currentDate.isBefore(DateTime(1900))
        ? currentDate
        : DateTime(2000, 1, 1);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      fieldLabelText: 'Fecha de nacimiento',
      fieldHintText: 'DD/MM/AAAA',
    );

    if (selectedDate == null || controller.isSaving) {
      return;
    }

    // Formato requerido por Laravel: YYYY-MM-DD
    final formattedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    controller.setBirthdate(formattedDate);
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final isUpdate =
        controller.view == CustomerViewType.update;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            // ==========================================
            // FORMULARIO
            // ==========================================

            AbsorbPointer(
              absorbing: controller.isSaving,
              child: PsSectionCard(
                title: isUpdate
                    ? 'Editar cliente'
                    : 'Información del cliente',
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // IDENTIFICACIÓN
                    // ==========================================

                    PsInput(
                      label: 'Identificación',
                      value:
                      controller.identificationDocument,
                      onChanged:
                      controller.setIdentificationDocument,
                      requiredField: true,
                      isTouched:
                      controller.identificationTouched,
                      error:
                      controller.identificationError,
                      isValid:
                      controller.identificationError ==
                          null,
                    ),

                    AppSpacing.spaceBetweenInputs,

                    // ==========================================
                    // NOMBRES
                    // ==========================================

                    PsInput(
                      label: 'Nombres',
                      value: controller.name,
                      onChanged: controller.setName,
                      requiredField: true,
                      isTouched: controller.nameTouched,
                      error: controller.nameError,
                      isValid:
                      controller.nameError == null,
                    ),

                    AppSpacing.spaceBetweenInputs,

                    // ==========================================
                    // APELLIDOS
                    // ==========================================

                    PsInput(
                      label: 'Apellidos',
                      value: controller.lastName,
                      onChanged: controller.setLastName,
                      requiredField: true,
                      isTouched:
                      controller.lastNameTouched,
                      error: controller.lastNameError,
                      isValid:
                      controller.lastNameError == null,
                    ),

                    AppSpacing.spaceBetweenInputs,

                    // ==========================================
                    // FECHA DE NACIMIENTO
                    // ==========================================

                    InkWell(
                      onTap: controller.isSaving
                          ? null
                          : () => _selectBirthdate(
                        context,
                      ),
                      borderRadius:
                      BorderRadius.circular(10),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText:
                          'Fecha de nacimiento *',
                          border:
                          const OutlineInputBorder(),
                          errorText:
                          controller.birthdateTouched
                              ? controller.birthdateError
                              : null,
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.birthdate.isEmpty
                                    ? 'Seleccionar fecha'
                                    : controller.birthdate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: controller
                                      .birthdate.isEmpty
                                      ? Theme.of(context)
                                      .hintColor
                                      : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    AppSpacing.spaceBetweenInputs,

                    // ==========================================
                    // GÉNERO
                    // ==========================================

                    DropdownButtonFormField<int>(
                      value: [0, 1, 2]
                          .contains(controller.gender)
                          ? controller.gender
                          : 0,
                      decoration: const InputDecoration(
                        labelText: 'Género',
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<int>(
                          value: 0,
                          child: Text(
                            'No especificado',
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text(
                            'Masculino',
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child: Text(
                            'Femenino',
                          ),
                        ),
                      ],
                      onChanged: controller.isSaving
                          ? null
                          : (value) {
                        if (value != null) {
                          controller.setGender(value);
                        }
                      },
                    ),

                    AppSpacing.spaceBetweenInputs,

                    // ==========================================
                    // CELULAR ECUADOR
                    // ==========================================

                    PsInput(
                      label: 'Celular',
                      value:
                      controller.informationPhoneValue,
                      onChanged: controller
                          .setInformationPhoneValue,
                      requiredField: true,
                      isTouched: controller.phoneTouched,
                      error: controller.phoneError,
                      isValid:
                      controller.phoneError == null,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Ejemplo: 0985339457 o +593985339457',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),

                    AppSpacing.spaceBetweenInputs,

                    // ==========================================
                    // CORREO ELECTRÓNICO
                    // ==========================================

                    PsInput(
                      label: 'Correo electrónico',
                      value: controller.email,
                      onChanged: controller.setEmail,
                      requiredField: true,
                      isTouched: controller.emailTouched,
                      error: controller.emailError,
                      isValid:
                      controller.emailError == null,
                    ),

                    // ==========================================
                    // ERROR DEL SERVIDOR
                    // ==========================================

                    if (controller.saveErrorMessage !=
                        null) ...[
                      AppSpacing.spaceBetweenInputs,

                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.08),
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .error,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                controller
                                    .saveErrorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ==========================================
            // LOADING BLOQUEANTE
            // ==========================================

            if (controller.isSaving)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black.withOpacity(0.40),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 42,
                              height: 42,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 4,
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              'Guardando cliente...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Por favor, espera un momento',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


class CustomerModelPosCurrent {
  // ==========================================
  // IDENTIFIERS
  // ==========================================

  final String id;
  final int peopleId;
  final int customerId;
  final int customerByInformationId;

  // ==========================================
  // PERSONAL INFORMATION
  // ==========================================

  final String identificationDocument;
  final int peopleTypeIdentificationId;
  final String peopleTypeIdentification;

  final String name;
  final String lastName;
  final String birthdate;
  final int age;
  final int gender;

  // ==========================================
  // CONTACT
  // ==========================================

  final String? email;
  final String? phone;
  final String? city;

  final int informationPhoneId;
  final int informationPhoneTypeId;
  final int informationPhoneOperatorId;

  final String informationPhoneType;
  final String informationPhoneOperator;

  // ==========================================
  // BUSINESS
  // ==========================================

  final String businessName;
  final String businessReason;
  final int rucTypeId;
  final String rucType;

  // ==========================================
  // NATIONALITY / PROFESSION
  // ==========================================

  final int peopleNationalityId;
  final int peopleProfessionId;

  final String peopleNationality;
  final String peopleProfession;

  // ==========================================
  // ADDRESS
  // ==========================================

  final int informationAddressId;
  final int informationAddressTypeId;

  final String informationAddressType;

  final String streetOne;
  final String streetTwo;
  final String reference;

  final String countryCodeId;
  final String administrativeAreaLevel1;
  final String administrativeAreaLevel2;
  final String administrativeAreaLevel3;

  final String optionsMap;

  // ==========================================
  // IMAGE
  // ==========================================

  final String? src;

  // ==========================================
  // ORIGINAL DATA
  // ==========================================

  final Map<String, dynamic> rawData;

  const CustomerModelPosCurrent({
    required this.id,
    required this.peopleId,
    required this.customerId,
    required this.customerByInformationId,
    required this.identificationDocument,
    required this.peopleTypeIdentificationId,
    required this.peopleTypeIdentification,
    required this.name,
    required this.lastName,
    required this.birthdate,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.city,
    required this.informationPhoneId,
    required this.informationPhoneTypeId,
    required this.informationPhoneOperatorId,
    required this.informationPhoneType,
    required this.informationPhoneOperator,
    required this.businessName,
    required this.businessReason,
    required this.rucTypeId,
    required this.rucType,
    required this.peopleNationalityId,
    required this.peopleProfessionId,
    required this.peopleNationality,
    required this.peopleProfession,
    required this.informationAddressId,
    required this.informationAddressTypeId,
    required this.informationAddressType,
    required this.streetOne,
    required this.streetTwo,
    required this.reference,
    required this.countryCodeId,
    required this.administrativeAreaLevel1,
    required this.administrativeAreaLevel2,
    required this.administrativeAreaLevel3,
    required this.optionsMap,
    required this.src,
    required this.rawData,
  });

  // ==========================================
  // HELPERS
  // ==========================================

  static int parseInt(
      dynamic value, [
        int fallback = -1,
      ]) {
    if (value == null) return fallback;

    if (value is Map) {
      return parseInt(value['id'], fallback);
    }

    return int.tryParse(value.toString()) ?? fallback;
  }

  static String parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  static String? parseNullableString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();

    return result.isEmpty ? null : result;
  }

  // ==========================================
  // FROM JSON
  // ==========================================

  factory CustomerModelPosCurrent.fromJson(
      Map<String, dynamic> json,
      ) {
    return CustomerModelPosCurrent(
      // IDENTIFIERS
      id: parseString(json['id']),
      peopleId: parseInt(json['people_id']),
      customerId: parseInt(json['customer_id']),
      customerByInformationId:
      parseInt(json['customer_by_information_id']),

      // PERSONAL INFORMATION
      identificationDocument:
      parseString(json['identification_document']),

      peopleTypeIdentificationId:
      parseInt(json['people_type_identification_id']),

      peopleTypeIdentification:
      parseString(json['people_type_identification']),

      name: parseString(json['name']),
      lastName: parseString(json['last_name']),
      birthdate: parseString(json['birthdate']),
      age: parseInt(json['age'], 0),
      gender: parseInt(json['gender'], 0),

      // CONTACT
      email: parseNullableString(json['email']),
      phone: parseNullableString(
        json['information_phone_value'],
      ),
      city: parseNullableString(json['city']),

      informationPhoneId:
      parseInt(json['information_phone_id']),

      informationPhoneTypeId:
      parseInt(json['information_phone_type_id']),

      informationPhoneOperatorId:
      parseInt(json['information_phone_operator_id']),

      informationPhoneType:
      parseString(json['information_phone_type']),

      informationPhoneOperator:
      parseString(json['information_phone_operator']),

      // BUSINESS
      businessName: parseString(json['business_name']),
      businessReason: parseString(json['business_reason']),
      rucTypeId: parseInt(json['ruc_type_id']),
      rucType: parseString(json['ruc_type']),

      // NATIONALITY / PROFESSION
      peopleNationalityId:
      parseInt(json['people_nationality_id']),

      peopleProfessionId:
      parseInt(json['people_profession_id']),

      peopleNationality:
      parseString(json['people_nationality']),

      peopleProfession:
      parseString(json['people_profession']),

      // ADDRESS
      informationAddressId:
      parseInt(json['information_address_id']),

      informationAddressTypeId:
      parseInt(json['information_address_type_id']),

      informationAddressType:
      parseString(json['information_address_type']),

      streetOne: parseString(json['street_one']),
      streetTwo: parseString(json['street_two']),
      reference: parseString(json['reference']),

      countryCodeId:
      parseString(json['country_code_id']),

      administrativeAreaLevel1:
      parseString(json['administrative_area_level_1']),

      administrativeAreaLevel2:
      parseString(json['administrative_area_level_2']),

      administrativeAreaLevel3:
      parseString(json['administrative_area_level_3']),

      optionsMap: parseString(json['options_map']),

      // IMAGE
      src: parseNullableString(json['src']),

      // ORIGINAL RESPONSE
      rawData: Map<String, dynamic>.from(json),
    );
  }

  // ==========================================
  // COMPUTED PROPERTIES
  // ==========================================

  String get fullName {
    return '$name $lastName'.trim();
  }

  String get displayName {
    return fullName.isNotEmpty
        ? fullName
        : 'Cliente sin nombre';
  }

  String get displayPhone {
    return phone?.isNotEmpty == true
        ? phone!
        : 'Sin teléfono';
  }

  String get displayIdentification {
    return identificationDocument.isNotEmpty
        ? identificationDocument
        : 'Sin identificación';
  }

  // ==========================================
  // FORMAT BIRTHDATE
  // ==========================================

  String get birthdateFormatted {
    if (birthdate.isEmpty) return '';

    final date = DateTime.tryParse(birthdate);

    if (date == null) return '';

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ==========================================
  // MAP FOR EDIT
  // ==========================================

  Map<String, dynamic> toEditMap() {
    return {
      'customer_id': customerId,

      'id': parseInt(id),
      'identification_document':
      identificationDocument,
      'people_type_identification_id':
      peopleTypeIdentificationId,
      'people_id': peopleId,
      'business_name': businessName,
      'business_reason': businessReason,
      'ruc_type_id': rucTypeId,
      'people_nationality_id': peopleNationalityId,
      'people_profession_id': peopleProfessionId,
      'last_name': lastName,
      'name': name,
      'birthdate': birthdateFormatted,
      'gender': gender,
      'age': age,
      'customer_by_information_id':
      customerByInformationId,
      'information_phone_id': informationPhoneId,
      'information_phone_value': phone ?? '',
      'information_phone_operator_id':
      informationPhoneOperatorId,
      'information_phone_type_id':
      informationPhoneTypeId,
      'email': email ?? '',
      'city': city ?? '',
    };
  }
}