
import '../widgets/sections/pos_layouts_utils.dart';
enum PosItemsSection { items, categories, modifiers, discounts, subcategories }

class PosItemsController extends PosSectionController<PosItemsSection> {
  PosItemsController() : super(PosItemsSection.items);

  String get sectionTitle {
    switch (section) {
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
