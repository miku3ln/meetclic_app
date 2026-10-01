import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/modals/manager-process-micro/ManagerProcessMicroConfig.dart';
import '../../../../shared/widgets/modals/manager-process-micro/ManagerProcessMicroResult.dart';
import '../../../../shared/widgets/modals/manager-process-micro/show_manager_process_micro.dart';
import '../widgets/layouts/pos_main_controller.dart';
import '../widgets/layouts/shift/manager/admin/shift_close_modal.dart';
import '../widgets/layouts/shift/manager/cash-movement/cash-movement-micro-controller.dart';
import '../widgets/layouts/shift/manager/cash-movement/cash-movement-micro-form.dart';
import '../widgets/layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';

class PosShiftManagementController extends ChangeNotifier {
  Map<String, dynamic>? _dataManagerCash;

  bool _allowManager = false;

  String _messageManager = '';

  Map<String, dynamic>? get dataManagerCash => _dataManagerCash;

  bool get allowManager => _allowManager;

  String get messageManager => _messageManager;

  /**
   * Actualiza la información general de administración
   * de la caja.
   */
  void setCashManagerData({
    required bool allowManager,
    required String messageManager,
    Map<String, dynamic>? data,
  }) {
    _allowManager = allowManager;
    _messageManager = messageManager;
    _dataManagerCash = data;

    notifyListeners();
  }

  /*
 * ============================================================
 * RELOAD CASH SUMMARY
 * ============================================================
 */

  bool _reloadCashSummary = false;

  bool get reloadCashSummary => _reloadCashSummary;

  void requestCashSummaryReload() {
    _reloadCashSummary = true;
    notifyListeners();
  }

  void clearCashSummaryReload() {
    _reloadCashSummary = false;
  }

  final PosMainController main;

  PosShiftManagementController({required this.main});

  bool _isClosingShift = false;

  bool get isClosingShift => _isClosingShift;

  bool get isShiftOpen => main.shift.isShiftOpen;

  double? get initialCash => main.shift.initialCash;

  Future<bool> onTreasuryTap(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return true;
  }

  Future<bool> onManagementMovement(BuildContext context) async {
    /*
   * ============================================================
   * CONTROLLER
   * ============================================================
   */
    final controller = CashMovementMicroController();

    /*
   * ============================================================
   * MODAL
   * ============================================================
   */

    final result = await showManagerProcessMicro<Map<String, dynamic>>(
      context: context,

      config: ManagerProcessMicroConfig(
        title: 'Gestión de movimiento',
        description: 'Registra un ingreso o egreso.',
        icon: Icons.account_balance_wallet_outlined,
        submitText: 'Guardar',
        cancelText: 'Cancelar',
      ),

      /*
     * ==========================================================
     * FORMULARIO
     * ==========================================================
     */
      form: CashMovementMicroForm(controller: controller),

      /*
     * ==========================================================
     * LISTENABLE
     * ==========================================================
     */
      listenable: controller,

      /*
     * ==========================================================
     * CAN SUBMIT
     * ==========================================================
     */
      canSubmit: () => controller.canSubmit,

      /*
     * ==========================================================
     * GUARDAR
     * ==========================================================
     */
      onSubmit: () async {
        /*
       * ========================================================
       * 1. VALIDACIÓN
       * ========================================================
       */

        final validation = controller.validateFields();

        if (!validation.success) {
          return ManagerProcessMicroResult<Map<String, dynamic>>(
            success: false,
            data: validation.errors,
            message: validation.message,
            type: 'validation',
          );
        }

        /*
       * ========================================================
       * 2. DATOS DEL FORMULARIO
       * ========================================================
       */
        /*
       * ========================================================
       * 3. GENERAR MOVIMIENTO DE CAJA
       * ========================================================
       */

        final responseSave = await UtilServicesCash.generateMovementCash(
          rode: controller.amount!,
          movementType: controller.movementTypeValue,
          cashReasonId: controller.cashReasonId!,
          details: controller.detailsValue,
          typesPaymentsId: controller.paymentTypeId!,
        );

        /*
       * ========================================================
       * 4. ERROR DEL SERVIDOR
       * ========================================================
       */

        if (!responseSave.success) {
          return ManagerProcessMicroResult<Map<String, dynamic>>(
            success: false,
            data: responseSave.data,
            message: responseSave.message.isNotEmpty
                ? responseSave.message
                : 'No se pudo registrar el movimiento.',
            type: 'save',
          );
        }

        /*
       * ========================================================
       * 5. MOVIMIENTO REGISTRADO
       * ========================================================
       */

        return ManagerProcessMicroResult<Map<String, dynamic>>(
          success: true,
          data: responseSave.data,
          message: responseSave.message.isNotEmpty
              ? responseSave.message
              : 'Movimiento registrado correctamente.',
          type: 'save',
        );
      },
    );

    /*
   * ============================================================
   * DISPOSE
   * ============================================================
   */

    controller.dispose();

    /*
   * ============================================================
   * CONTEXT
   * ============================================================
   */

    if (!context.mounted) {
      return false;
    }

    /*
   * ============================================================
   * ERROR
   * ============================================================
   */

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

      return false;
    }

    /*
   * ============================================================
   * RESULTADO
   * ============================================================
   */

    switch (result.type) {
      case 'save':
        /*
       * Aquí puedes refrescar la información de caja.
       *
       * await _refreshAll();
       */

        if (!context.mounted) {
          return false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty
                  ? result.message
                  : 'Movimiento realizado correctamente.',
            ),
          ),
        );

        requestCashSummaryReload();

        return true;

      case 'close':
        debugPrint('Cerrar SIN reload');
        return false;

      case 'cancel':
        debugPrint('Cancelar SIN reload');
        return false;

      default:
        return false;
    }
  }

  Future<bool> onCloseShiftTap(BuildContext context) async {
    final ShiftCloseModalResult result = await ShiftCloseModal.show(
      context: context,
      dataManagerCash: dataManagerCash!,
      onCashDrawerTap: onCashDrawerTap,
      onTheoreticalCashTap: onTheoreticalCashTap,
      onSubmit:
          ({
            required double closingAmount,
            required String closingDetails,
          }) async {
            final response = await UtilServicesCash.closeCash(
              amount: closingAmount,
              details: closingDetails,
            );

            final bool success = response.success == true;

            if (!success) {
              return ShiftCloseModalResult(
                success: false,
                message: response.message ?? 'No se pudo cerrar el turno.',
                type: ShiftCloseModal.error,
                data: response.data is Map<String, dynamic>
                    ? response.data as Map<String, dynamic>
                    : null,
              );
            }
            return ShiftCloseModalResult(
              success: true,
              message:
                  response.message.toString() ,
              type: ShiftCloseModal.confirmed,
              data: response.data,
            );
          },
    );
    if (!result.success) {
      debugPrint(result.message);
      return false;
    }
    if (result.type != ShiftCloseModal.confirmed) {
      return false;
    }
    return result.success;
  }

  void onCashDrawerTap() {
    debugPrint('Click: Cajón de efectivo');
  }

  void onSalesSummaryTap() {
    debugPrint('Click: Resumen de ventas');
  }

  void onPaymentsSummaryTap() {
    debugPrint('Click: Total licitado');
  }

  void onPreviousCashDrawerTap() {
    debugPrint('Click: Fondo de caja anterior');
  }

  void onCashPaymentsTap() {
    debugPrint('Click: Cobros en efectivo');
  }

  void onCashRefundsTap() {
    debugPrint('Click: Reembolsos en efectivo');
  }

  void onDepositedTap() {
    debugPrint('Click: Depositado');
  }

  void onPayoutsTap() {
    debugPrint('Click: Pagos/Salidas');
  }

  void onTheoreticalCashTap() {
    debugPrint('Click: Efectivo teórico en caja');
  }

  void onGrossSalesTap() {
    debugPrint('Click: Ventas brutas');
  }

  void onRefundsTap() {
    debugPrint('Click: Reembolsos');
  }

  void onDiscountsTap() {
    debugPrint('Click: Descuentos');
  }

  void onNetSalesTap() {
    debugPrint('Click: Ventas netas');
  }

  void onTaxesTap() {
    debugPrint('Click: Impuestos');
  }

  void onTenderedTotalTap() {
    debugPrint('Click: Total licitado');
  }

  void onCashTap() {
    debugPrint('Click: Efectivo');
  }

  void onCashRoundingTap() {
    debugPrint('Click: Redondeo de efectivo');
  }

  void onCardTap() {
    debugPrint('Click: Por tarjeta');
  }



  Future<void> closeShift(BuildContext context) async {
    final wasClosed = await onCloseShiftTap(context);
    if (!wasClosed) {
      return;
    }
    // Actualiza el estado principal del POS.
    await main.shift.closeShift();
    // Solicita al PosShiftRegister que vuelva a consultar el resumen.
    _reloadCashSummary = true;
    notifyListeners();
  }

}
