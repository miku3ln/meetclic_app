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

  String get sectionTitle {
    switch (_section) {
      case PosSettingsSection.printers:
        return 'Impresoras';

      case PosSettingsSection.customerScreen:
        return 'Pantalla para clientes';

      case PosSettingsSection.taxes:
        return 'Impuestos';

      case PosSettingsSection.general:
        return 'General';
    }
  }
}