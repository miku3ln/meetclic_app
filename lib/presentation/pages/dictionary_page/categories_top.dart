import 'package:flutter/material.dart';

/// ===============================
/// MODELO
/// ===============================

/// Item del carrusel de categorías.
/// - [id]: identificador único (mapea con tus constantes/grupos).
/// - [name]: etiqueta mostrada.
/// - [asset]: ruta del ícono (si usas assets).
/// - [number]: métrica (conteo, porcentaje, etc.)
/// - [icon]: alternativa si prefieres usar IconData en vez de asset.
/// - [onTap]: hook opcional al tocar.
class CategoriesCarouselItem {
  final int id;
  final String name;
  final String? asset;
  final IconData? icon;
  final double number;
  final VoidCallback? onTap;

  const CategoriesCarouselItem({
    required this.id,
    required this.name,
    this.asset,
    this.icon,
    this.number = 0,
    this.onTap,
  }) : assert(
         asset != null || icon != null,
         'Define al menos asset o icon para el item',
       );
}

/// ===============================
/// CONSTANTES DE CLASES GRAMATICALES
/// ===============================

class GrammaticalClass {
  static const int sustantivo = 1;
  static const int verbo = 2;
  static const int adjetivo = 3;
  static const int adverbio = 4;
  static const int pronombre = 5;
  static const int articulo = 6;
  static const int preposicion = 7;
  static const int conjuncion = 8;
  static const int interjeccion = 9;
  static const int determinante = 10;
  static const int numeral = 11;
  static const int particula = 12;
  static const int auxiliarVerbal = 13;
}

/// ===============================
/// CATÁLOGO BASE
/// Cambia assets o usa icon en su lugar
/// ===============================

final List<CategoriesCarouselItem> grammaticalClassCatalog = [
  CategoriesCarouselItem(
    id: GrammaticalClass.sustantivo,
    name: 'Sustantivo',
    asset: 'assets/icons/sustantivo.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.verbo,
    name: 'Verbo',
    asset: 'assets/icons/verbo.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.adjetivo,
    name: 'Adjetivo',
    asset: 'assets/icons/adjetivo.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.adverbio,
    name: 'Adverbio',
    asset: 'assets/icons/adverbio.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.pronombre,
    name: 'Pronombre',
    asset: 'assets/icons/pronombre.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.articulo,
    name: 'Artículo',
    asset: 'assets/icons/articulo.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.preposicion,
    name: 'Preposición',
    asset: 'assets/icons/preposicion.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.conjuncion,
    name: 'Conjunción',
    asset: 'assets/icons/conjuncion.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.interjeccion,
    name: 'Interjección',
    asset: 'assets/icons/interjeccion.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.determinante,
    name: 'Determinante',
    asset: 'assets/icons/determinante.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.numeral,
    name: 'Numeral',
    asset: 'assets/icons/numeral.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.particula,
    name: 'Partícula',
    asset: 'assets/icons/particula.png',
    number: 0,
  ),
  CategoriesCarouselItem(
    id: GrammaticalClass.auxiliarVerbal,
    name: 'Auxiliar verbal',
    asset: 'assets/icons/auxiliar.png',
    number: 0,
  ),
];

/// ===============================
/// CONTROLADOR (selección por id)
/// ===============================

class CategoryController extends ChangeNotifier {
  CategoryController({
    List<CategoriesCarouselItem>? items,
    int? initialSelectedId,
  }) : _items = items ?? const [],
       _selectedId = initialSelectedId;

  List<CategoriesCarouselItem> _items;
  int? _selectedId;

  List<CategoriesCarouselItem> get items => _items;
  int? get selectedId => _selectedId;

  set items(List<CategoriesCarouselItem> value) {
    _items = value;
    // Si el id seleccionado ya no existe, límpialo
    if (_selectedId != null && !_items.any((e) => e.id == _selectedId)) {
      _selectedId = null;
    }
    notifyListeners();
  }

  void selectById(int id) {
    if (_selectedId == id) return;
    _selectedId = id;
    // dispara hook del item si existe
    final it = _items.firstWhere((e) => e.id == id, orElse: () => _items.first);
    it.onTap?.call();
    notifyListeners();
  }
}

/// ===============================
/// WIDGET: Carrusel de Categorías
/// ===============================

typedef ItemLabelBuilder = String Function(CategoriesCarouselItem item);
typedef ItemLeadingBuilder =
    Widget? Function(CategoriesCarouselItem item, bool selected);

class CategoryCarousel extends StatelessWidget {
  final CategoryController controller;
  final bool scrollLocked;
  final ItemLabelBuilder? labelBuilder;
  final ItemLeadingBuilder? leadingBuilder;
  final ValueChanged<int>? onChanged; // devuelve selectedId
  final bool showNumberBadge;

  // Estilos (puedes cambiarlos o integrar tu tema)
  final Color selectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color borderColor;
  final Color backgroundColor;

  const CategoryCarousel({
    Key? key,
    required this.controller,
    this.scrollLocked = false,
    this.labelBuilder,
    this.leadingBuilder,
    this.onChanged,
    this.showNumberBadge = false,
    this.selectedColor = const Color(0xFF1565C0), // azul
    this.selectedTextColor = const Color(0xFF1565C0), // azul
    this.unselectedTextColor = const Color(0xFF37474F), // gris oscuro
    this.borderColor = const Color(0xFF7E57C2), // morado suave
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  String _defaultLabel(CategoriesCarouselItem it) => it.name;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.items;
        final selectedId = controller.selectedId;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: scrollLocked
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = item.id == selectedId;
              final label = (labelBuilder ?? _defaultLabel).call(item);
              final leading = leadingBuilder?.call(item, selected);

              return Padding(
                padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) ...[
                        leading,
                        const SizedBox(width: 6),
                      ] else if (item.asset != null) ...[
                        Image.asset(
                          item.asset!,
                          width: 16,
                          height: 16,
                          color: selected
                              ? selectedTextColor
                              : unselectedTextColor,
                        ),
                        const SizedBox(width: 6),
                      ] else if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 16,
                          color: selected
                              ? selectedTextColor
                              : unselectedTextColor,
                        ),
                        const SizedBox(width: 6),
                      ] else ...[
                        const Icon(Icons.category_outlined, size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(label),
                      if (showNumberBadge && item.number > 0) ...[
                        const SizedBox(width: 6),
                        _NumberBadge(value: item.number),
                      ],
                    ],
                  ),
                  selected: selected,
                  onSelected: (_) {
                    controller.selectById(item.id);
                    onChanged?.call(item.id);
                  },
                  selectedColor: selectedColor.withOpacity(.12),
                  labelStyle: TextStyle(
                    color: selected ? selectedTextColor : unselectedTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected
                        ? selectedColor
                        : borderColor.withOpacity(.2),
                  ),
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final double value;
  const _NumberBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    final text = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
