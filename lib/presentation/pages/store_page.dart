import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/store_page/services/store_mapper_service.dart';
import 'package:meetclic_app/presentation/pages/store_page/state/store_state.dart';
import 'package:meetclic_app/presentation/pages/store_page/widgets/organisms/store_categories_list_organism.dart';
import 'package:meetclic_app/presentation/pages/store_page/widgets/organisms/store_products_grid_organism.dart';

import '../../../domain/entities/menu_tab_up_item.dart';
import '../widgets/template/custom_app_bar.dart';

class StorePage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const StorePage({super.key, required this.title, required this.itemsStatus});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late StoreState _state;
  final _mapper = const StoreMapperService();

  @override
  void initState() {
    super.initState();
    final categories = _mapper.buildCategories();
    final products = _mapper.buildProducts();

    _state = StoreState(
      categories: categories,
      products: products,
      selectedCategoryId: categories.first.id,
    );
  }

  void _onCategorySelected(int id) {
    setState(() {
      _state = _state.copyWith(selectedCategoryId: id);
    });
  }

  void _onAddProduct() {
    // Aquí luego conectas con carrito, yapitas, etc.
    debugPrint('🛒 Producto añadido al carrito (StorePage)');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: Column(
        children: [
          const SizedBox(height: 12),
          StoreCategoriesListOrganism(
            categories: _state.categories,
            selectedCategoryId: _state.selectedCategoryId,
            onCategorySelected: _onCategorySelected,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StoreProductsGridOrganism(
              products: _state.filteredProducts,
              onAddProduct: _onAddProduct,
            ),
          ),
        ],
      ),
    );
  }
}
