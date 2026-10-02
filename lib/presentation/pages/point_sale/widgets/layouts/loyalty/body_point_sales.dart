import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class PosProductCatalogContent extends StatefulWidget {
  const PosProductCatalogContent({
    super.key,
  });

  @override
  State<PosProductCatalogContent> createState() =>
      _PosProductCatalogContentState();
}

class _PosProductCatalogContentState
    extends State<PosProductCatalogContent> {
  final TextEditingController _searchController =
  TextEditingController();

  final FocusNode _searchFocusNode =
  FocusNode(debugLabel: 'posProductSearch');
  String _selectedCategory = 'Todos';

  String _selectedServiceType = 'Para servirse';

  final List<String> _categories = const [
    'Todos',
    'Productos Artesanales',
    'Materia Prima',
    'Bebidas',
    'Cárnicos',
  ];

  final List<String> _serviceTypes = const [
    'Para servirse',
    'Para llevar',
    'Delivery',
  ];

  final List<PosCatalogProduct> _products = const [
    PosCatalogProduct(
      id: 1,
      name: 'Ensalada',
      price: 1.00,
      category: 'Productos Artesanales',
      imageUrl:
      'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=600',
    ),
    PosCatalogProduct(
      id: 2,
      name: 'Prueba',
      price: 1.00,
      category: 'Bebidas',
      imageUrl:
      'https://images.unsplash.com/photo-1556881286-fc6915169721?w=600',
    ),
    PosCatalogProduct(
      id: 3,
      name: 'Aliño en polvo 13',
      price: 0.50,
      category: 'Materia Prima',
      imageUrl:
      'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=600',
    ),
    PosCatalogProduct(
      id: 4,
      name: 'Alitas',
      price: 2.00,
      category: 'Cárnicos',
      imageUrl:
      'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600',
    ),
    PosCatalogProduct(
      id: 5,
      name: 'Pollo entero',
      price: 7.00,
      category: 'Cárnicos',
      imageUrl:
      'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=600',
    ),
    PosCatalogProduct(
      id: 6,
      name: 'Alas',
      price: 1.80,
      category: 'Cárnicos',
      imageUrl:
      'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=600',
    ),
    PosCatalogProduct(
      id: 7,
      name: 'Carne de res',
      price: 3.00,
      category: 'Cárnicos',
      imageUrl:
      'https://images.unsplash.com/photo-1603048297172-c92544798d5a?w=600',
    ),
    PosCatalogProduct(
      id: 8,
      name: 'Huevos',
      price: 0.50,
      category: 'Materia Prima',
      imageUrl:
      'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=600',
    ),
    PosCatalogProduct(
      id: 9,
      name: 'Aceite',
      price: 2.00,
      category: 'Materia Prima',
      imageUrl:
      'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=600',
    ),
    PosCatalogProduct(
      id: 10,
      name: 'Salsa',
      price: 3.00,
      category: 'Productos Artesanales',
      imageUrl:
      'https://images.unsplash.com/photo-1472476443507-c7a5948772fc?w=600',
    ),
  ];

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<PosCatalogProduct> get _filteredProducts {
    final search =
    _searchController.text.trim().toLowerCase();

    return _products.where((product) {
      final matchesSearch =
          search.isEmpty ||
              product.name.toLowerCase().contains(search);

      final matchesCategory =
          _selectedCategory == 'Todos' ||
              product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _selectProduct(
      PosCatalogProduct product,
      ) {
    // ==========================================================
    // AQUÍ CONECTAREMOS DESPUÉS TU CONTROLLER REAL
    // ==========================================================

    debugPrint(
      'Producto seleccionado: ${product.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Container(
      color: const Color(0xFFF8F8FC),
      child: Column(
        children: [
          // ====================================================
          // FILTROS
          // ====================================================

          _buildFilters(),

          // ====================================================
          // PRODUCTOS
          // ====================================================

          Expanded(
            child: products.isEmpty
                ? const _PosEmptyProducts()
                : _PosProductGrid(
              products: products,
              onProductTap: _selectProduct,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        10,
      ),
      child: Column(
        children: [
          // ====================================================
          // SEARCH + SERVICE TYPE
          // ====================================================

          Row(
            children: [
              // =================================================
              // SEARCH
              // =================================================

              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF4D4DFF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // =================================================
              // SERVICE TYPE
              // =================================================

              Expanded(
                flex: 4,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F4),
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedServiceType,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                      ),
                      items: _serviceTypes.map(
                            (service) {
                          return DropdownMenuItem<String>(
                            value: service,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.restaurant_rounded,
                                  size: 19,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    service,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedServiceType = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ====================================================
          // CATEGORIES
          // ====================================================

          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (
                  context,
                  index,
                  ) {
                return const SizedBox(width: 8);
              },
              itemBuilder: (
                  context,
                  index,
                  ) {
                final category =
                _categories[index];

                final selected =
                    category ==
                        _selectedCategory;

                return _PosCategoryButton(
                  label: category,
                  selected: selected,
                  onTap: () {
                    setState(() {
                      _selectedCategory =
                          category;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PRODUCT GRID
// ============================================================================

class _PosProductGrid extends StatelessWidget {
  final List<PosCatalogProduct> products;

  final ValueChanged<PosCatalogProduct>
  onProductTap;

  const _PosProductGrid({
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        // ========================================================
        // RESPONSIVE
        // ========================================================

        int columns = 2;

        if (constraints.maxWidth >= 900) {
          columns = 5;
        } else if (constraints.maxWidth >=
            650) {
          columns = 4;
        } else if (constraints.maxWidth >=
            480) {
          columns = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            12,
            4,
            12,

            // Espacio extra porque encima estará
            // nuestro ticket draggable.
            180,
          ),
          physics:
          const BouncingScrollPhysics(),
          itemCount: products.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (
              context,
              index,
              ) {
            final product =
            products[index];

            return _PosProductCard(
              product: product,
              onTap: () {
                onProductTap(product);
              },
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// PRODUCT CARD
// ============================================================================

class _PosProductCard extends StatelessWidget {
  final PosCatalogProduct product;

  final VoidCallback onTap;

  const _PosProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            _PosProductImage(
              imageUrl: product.imageUrl,
            ),

            // ==================================================
            // GRADIENT
            // ==================================================

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:
                  Alignment.topCenter,
                  end:
                  Alignment.bottomCenter,
                  stops: [
                    0.35,
                    1.0,
                  ],
                  colors: [
                    Colors.transparent,
                    Color(0xC9000000),
                  ],
                ),
              ),
            ),

            // ==================================================
            // PRICE
            // ==================================================

            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                  const Color(
                    0xFF2962FF,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    50,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color:
                      Color(
                        0x22000000,
                      ),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),

            // ==================================================
            // NAME
            // ==================================================

            Positioned(
              left: 10,
              right: 10,
              bottom: 9,
              child: Text(
                product.name,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.1,
                  fontWeight:
                  FontWeight.w800,
                  shadows: [
                    Shadow(
                      color:
                      Color(
                        0x66000000,
                      ),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCT IMAGE
// ============================================================================

class _PosProductImage
    extends StatelessWidget {
  final String? imageUrl;

  const _PosProductImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null ||
        imageUrl!.trim().isEmpty) {
      return const _PosProductPlaceholder();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return const _PosProductPlaceholder();
      },
      loadingBuilder: (
          context,
          child,
          loadingProgress,
          ) {
        if (loadingProgress == null) {
          return child;
        }

        return const _PosProductPlaceholder(
          showLoading: true,
        );
      },
    );
  }
}

// ============================================================================
// IMAGE PLACEHOLDER
// ============================================================================

class _PosProductPlaceholder
    extends StatelessWidget {
  final bool showLoading;

  const _PosProductPlaceholder({
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9E9EF),
      alignment: Alignment.center,
      child: showLoading
          ? const SizedBox(
        width: 22,
        height: 22,
        child:
        CircularProgressIndicator(
          strokeWidth: 2,
        ),
      )
          : Icon(
        Icons.image_outlined,
        size: 30,
        color:
        Colors.grey.shade500,
      ),
    );
  }
}

// ============================================================================
// CATEGORY BUTTON
// ============================================================================

class _PosCategoryButton
    extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PosCategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary =
    Color(0xFF4D4DFF);

    return Material(
      color: selected
          ? const Color(0xFFF0F0FF)
          : Colors.white,
      borderRadius:
      BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(12),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? primary
                  : const Color(
                0xFFE0E0E8,
              ),
              width:
              selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: selected
                  ? primary
                  : const Color(
                0xFF29293D,
              ),
              fontSize: 14,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY PRODUCTS
// ============================================================================

class _PosEmptyProducts
    extends StatelessWidget {
  const _PosEmptyProducts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 44,
            color: Colors.grey,
          ),

          SizedBox(height: 10),

          Text(
            'No se encontraron productos',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODEL
// ============================================================================

class PosCatalogProduct {
  final int id;
  final String name;
  final double price;
  final String category;
  final String? imageUrl;

  const PosCatalogProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
  });
}