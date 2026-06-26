import 'package:flutter/foundation.dart';

enum PosItemsSection { items, categories, modifiers, discounts, subcategories }

class PosItemsController extends ChangeNotifier {
  PosItemsSection _section = PosItemsSection.items;

  PosItemsSection get section => _section;

  void setSection(PosItemsSection value) {
    if (_section == value) return;
    _section = value;
    notifyListeners();
  }

  String get sectionTitle {
    switch (_section) {
      case PosItemsSection.items:
        return 'Artículos';
      case PosItemsSection.categories:
        return 'Categorías';

      case PosItemsSection.modifiers:
        return 'Modificadores';
      case PosItemsSection.discounts:
        return 'Descuentos';

      case PosItemsSection.subcategories:
        return 'Subcategorias';
    }
  }
}
