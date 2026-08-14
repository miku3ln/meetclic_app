
import '../widgets/sections/pos_layouts_utils.dart';

enum PosSettingsSection {
  printers,
  customerScreen,
  taxes,
  general,
}

class PosSettingsController    extends PosSectionController<PosSettingsSection> {
  PosSettingsController()
      : super(PosSettingsSection.printers);
  String get sectionTitle {
    switch (section) {
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