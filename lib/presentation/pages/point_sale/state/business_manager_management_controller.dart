import 'package:flutter/foundation.dart';

class BusinessManagerManagementController extends ChangeNotifier {
  bool _isClosingShift = false;

  bool get isClosingShift => _isClosingShift;

  Future<bool>  onTreasuryTap() async{
    await Future.delayed(const Duration(milliseconds: 500));

    return true;
  }

  Future<bool> onCloseShiftTap() async {
    if (_isClosingShift) return false;

    _isClosingShift = true;
    notifyListeners();

    try {
      debugPrint('Click: Cerrar el turno');

      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      debugPrint('Error al cerrar el turno: $e');
      return false;
    } finally {
      _isClosingShift = false;
      notifyListeners();
    }
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
}
