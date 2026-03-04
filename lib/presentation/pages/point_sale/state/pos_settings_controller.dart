import 'package:flutter/foundation.dart';

enum PosSettingsSection {
  printers,
  customerScreen,
  taxes,
  general,
}

class PosSettingsController extends ChangeNotifier {
  PosSettingsSection _section = PosSettingsSection.customerScreen;
  PosSettingsSection get section => _section;

  void setSection(PosSettingsSection value) {
    if (_section == value) return;
    _section = value;
    notifyListeners();
  }
}