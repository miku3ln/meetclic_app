import 'package:flutter/foundation.dart';
class PosShiftState extends ChangeNotifier {
  VoidCallback? onRequestOpenShift;

  bool isShiftOpen = false;

  void onOpenShiftTap() => onRequestOpenShift?.call();

  Future<void> openShift(double initialCash) async {
    isShiftOpen = true;
    notifyListeners();
  }

  bool get canSell => isShiftOpen;
}