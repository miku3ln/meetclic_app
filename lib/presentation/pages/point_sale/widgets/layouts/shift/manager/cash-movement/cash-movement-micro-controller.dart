import '../../../../../../../../shared/pagination_response.dart';
import '../../../../../../../../shared/utils/validators/validators.dart';

class CashMovementMicroController extends BaseFormController {
  /*
   * ============================================================
   * MOVEMENT TYPE
   *
   * Backend:
   * 0 = INGRESO
   * 1 = EGRESO
   * ============================================================
   */

  static const String movementTypeIncome = 'INCOME';
  static const String movementTypeOutcome = 'OUTCOME';

  /*
   * ============================================================
   * PAYMENT TYPES
   *
   * Backend -> types_payments_id
   *
   * 1 = Efectivo
   * 2 = Tarjeta de crédito
   * 3 = Cheque
   * 4 = Transferencia
   * 5 = Dinero electrónico
   * 6 = Tarjeta de débito
   * ============================================================
   */

  static const int paymentTypeCash = 1;
  static const int paymentTypeCreditCard = 2;
  static const int paymentTypeCheck = 3;
  static const int paymentTypeTransfer = 4;
  static const int paymentTypeElectronicMoney = 5;
  static const int paymentTypeDebitCard = 6;

  /*
   * ============================================================
   * TRANSACTION TYPE
   *
   * Backend:
   * 0 = INDIRECTO
   * 1 = DIRECTO
   * ============================================================
   */

  static const String transactionTypeIndirect = 'INDIRECT';
  static const String transactionTypeDirect = 'DIRECT';

  /*
   * ============================================================
   * FIELDS
   * ============================================================
   */

  late final FormFieldController<String> movementTypeField;

  late final FormFieldController<int> cashReasonField;

  late final FormFieldController<double> amountField;

  late final FormFieldController<String> transactionTypeField;

  late final FormFieldController<int> paymentTypeField;

  late final FormFieldController<String> detailsField;

  /*
   * ============================================================
   * SELECTED DATA
   * ============================================================
   */

  GenericListItem<Map<String, dynamic>>? selectedCashReason;

  /*
   * ============================================================
   * CONSTRUCTOR
   * ============================================================
   */

  CashMovementMicroController() {
    /*
     * TIPO DE MOVIMIENTO
     */

    movementTypeField = FormFieldController<String>(
      label: 'Tipo de movimiento',
      value: movementTypeIncome,
      validators: [ValidatorsUtil.required('Tipo de movimiento')],
    );

    /*
     * MOTIVO
     */

    cashReasonField = FormFieldController<int>(
      label: 'Motivo',
      validators: [ValidatorsUtil.requiredInt('Motivo')],
    );

    /*
     * VALOR
     */

    amountField = FormFieldController<double>(
      label: 'Valor',
      validators: [ValidatorsUtil.positiveDouble('Valor')],
    );

    /*
     * TIPO DE TRANSACCIÓN
     */

    transactionTypeField = FormFieldController<String>(
      label: 'Tipo de transacción',
      value: transactionTypeDirect,
      validators: [ValidatorsUtil.required('Tipo de transacción')],
    );

    /*
     * FORMA DE PAGO
     *
     * Por defecto:
     * Efectivo -> ID 1
     */

    paymentTypeField = FormFieldController<int>(
      label: 'Forma de pago',
      value: paymentTypeCash,
      validators: [ValidatorsUtil.requiredInt('Forma de pago')],
    );

    /*
     * DETALLE
     *
     * Opcional.
     */

    detailsField = FormFieldController<String>(label: 'Detalle');

    /*
     * ============================================================
     * REGISTRAR FIELDS
     * ============================================================
     */

    fields.addAll({
      'movementType': movementTypeField,
      'cashReason': cashReasonField,
      'amount': amountField,
      'transactionType': transactionTypeField,
      'paymentType': paymentTypeField,
      'details': detailsField,
    });
  }

  /*
   * ============================================================
   * VALUES
   * ============================================================
   */

  String? get movementType => movementTypeField.value;

  int? get cashReasonId => cashReasonField.value;

  double? get amount => amountField.value;

  String? get transactionType => transactionTypeField.value;

  int? get paymentTypeId => paymentTypeField.value;

  String? get details => detailsField.value;

  /*
   * ============================================================
   * LABELS
   * ============================================================
   */

  String get movementTypeLabel => movementTypeField.label;

  String get cashReasonLabel => cashReasonField.label;

  String get amountLabel => amountField.label;

  String get transactionTypeLabel => transactionTypeField.label;

  String get paymentTypeLabel => paymentTypeField.label;

  String get detailsLabel => detailsField.label;

  /*
   * ============================================================
   * ERRORS
   * ============================================================
   */

  String? get movementTypeError => movementTypeField.error;

  String? get cashReasonError => cashReasonField.error;

  String? get amountError => amountField.error;

  String? get transactionTypeError => transactionTypeField.error;

  String? get paymentTypeError => paymentTypeField.error;

  String? get detailsError => detailsField.error;

  /*
   * ============================================================
   * TOUCHED
   * ============================================================
   */

  bool get movementTypeTouched => movementTypeField.touched;

  bool get cashReasonTouched => cashReasonField.touched;

  bool get amountTouched => amountField.touched;

  bool get transactionTypeTouched => transactionTypeField.touched;

  bool get paymentTypeTouched => paymentTypeField.touched;

  bool get detailsTouched => detailsField.touched;

  /*
   * ============================================================
   * SETTERS
   * ============================================================
   */

  void setMovementType(String? value) {
    movementTypeField.setValue(value);

    /*
     * Si cambia INGRESO / EGRESO,
     * el motivo seleccionado anteriormente
     * deja de ser válido.
     */

    cashReasonField.value = null;
    cashReasonField.error = null;
    cashReasonField.touched = false;

    selectedCashReason = null;

    notifyListeners();
  }

  void setCashReason(GenericListItem<Map<String, dynamic>>? item) {
    /*
     * Guardar objeto seleccionado para la UI.
     */

    selectedCashReason = item;

    /*
     * Si se limpia la selección.
     */

    if (item == null) {
      cashReasonField.setValue(null);
      notifyListeners();
      return;
    }

    /*
     * Obtener ID.
     */

    final dynamic idValue = item.id;

    final int? cashReasonId = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '');

    /*
     * Guardar ID para backend.
     */

    cashReasonField.setValue(cashReasonId);

    notifyListeners();
  }

  void setAmount(String value) {
    final normalized = value.trim().replaceAll(',', '.');

    amountField.setValue(double.tryParse(normalized));

    notifyListeners();
  }

  void setTransactionType(String? value) {
    transactionTypeField.setValue(value);

    notifyListeners();
  }

  void setPaymentType(int? value) {
    paymentTypeField.setValue(value);

    notifyListeners();
  }

  void setDetails(String value) {
    detailsField.setValue(value);

    notifyListeners();
  }

  /*
   * ============================================================
   * MAPEO MOVEMENT TYPE
   *
   * Flutter:
   * INCOME / OUTCOME
   *
   * Backend:
   * 0 / 1
   * ============================================================
   */

  int get movementTypeValue {
    return movementType == movementTypeIncome ? 0 : 1;
  }

  /*
   * ============================================================
   * MAPEO TRANSACTION TYPE
   *
   * Flutter:
   * INDIRECT / DIRECT
   *
   * Backend:
   * 0 / 1
   * ============================================================
   */

  int get transactionTypeValue {
    return transactionType == transactionTypeIndirect ? 0 : 1;
  }

  /*
   * ============================================================
   * VALUES PARA API
   * ============================================================
   */

  int get cashReasonIdValue => cashReasonId ?? 0;

  double get amountValue => amount ?? 0;

  int get paymentTypeIdValue => paymentTypeId ?? 0;

  String get detailsValue => details?.trim() ?? '';

  /*
   * ============================================================
   * PAYLOAD
   * ============================================================
   */

  Map<String, dynamic> toPayload() {
    return {
      'movement_type': movementTypeValue,

      'cash_reason_id': cashReasonIdValue,

      'details': detailsValue,

      'rode': amountValue,

      'transaction_type': transactionTypeValue,

      'types_payments_id': paymentTypeIdValue,
    };
  }

  /*
   * ============================================================
   * CAN SUBMIT
   * ============================================================
   */

  bool get canSubmit {
    /*
     * MOVEMENT TYPE
     */

    if (movementType == null || movementType!.trim().isEmpty) {
      return false;
    }

    /*
     * CASH REASON
     */

    if (cashReasonId == null || cashReasonId! <= 0) {
      return false;
    }

    /*
     * AMOUNT
     */

    if (amount == null || amount! <= 0) {
      return false;
    }

    /*
     * TRANSACTION TYPE
     */

    if (transactionType == null || transactionType!.trim().isEmpty) {
      return false;
    }

    /*
     * PAYMENT TYPE
     */

    if (paymentTypeId == null || paymentTypeId! <= 0) {
      return false;
    }

    /*
     * DETAILS
     *
     * Opcional.
     */

    /*
     * ERRORES DE VALIDACIÓN
     */

    if (movementTypeError != null) {
      return false;
    }

    if (cashReasonError != null) {
      return false;
    }

    if (amountError != null) {
      return false;
    }

    if (transactionTypeError != null) {
      return false;
    }

    if (paymentTypeError != null) {
      return false;
    }

    return true;
  }
}