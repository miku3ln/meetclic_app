import 'package:flutter/material.dart';

import '../models/pos_payment_method.dart';


class PosPaymentState extends ChangeNotifier {
  PosPaymentMethod _paymentMethod = PosPaymentMethod.cash;

  PosPaymentMethod get paymentMethod => _paymentMethod;

  bool get isCash => _paymentMethod == PosPaymentMethod.cash;
  bool get isCard => _paymentMethod == PosPaymentMethod.card;
  bool get isQr => _paymentMethod == PosPaymentMethod.qr;

  void setPaymentMethod(PosPaymentMethod value) {
    if (_paymentMethod == value) return;
    _paymentMethod = value;
    notifyListeners();
  }

  String get paymentMethodCode {
    switch (_paymentMethod) {
      case PosPaymentMethod.cash:
        return 'CASH';
      case PosPaymentMethod.card:
        return 'CARD';
      case PosPaymentMethod.qr:
        return 'QR';
    }
  }
}