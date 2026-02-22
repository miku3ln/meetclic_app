import 'package:flutter/material.dart';
import '../organisms/pos_header_bar.dart';
import '../models/pos_product_item.dart'; // PosCategoryItem
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';

class PosMobileLandscapeLayout extends StatefulWidget {
  const PosMobileLandscapeLayout({super.key});

  @override
  State<PosMobileLandscapeLayout> createState() =>
      _PosMobileLandscapeLayoutState();
}

class _PosMobileLandscapeLayoutState extends State<PosMobileLandscapeLayout> {
  // ✅ (1) dropdown: product categories
  late final List<PosCategoryItem> productCategories;
  String? selectedProductCategoryId;

  // ✅ (3) search
  String query = '';

  @override
  void initState() {
    super.initState();
    productCategories = PosTabletLandscapeFixtures.getCategoriesData();
    selectedProductCategoryId =
    productCategories.isNotEmpty ? productCategories.first.id : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PosHeaderBar(
        productCategories: productCategories,
        selectedProductCategoryId: selectedProductCategoryId,
        onProductCategoryChanged: (id) {
          setState(() => selectedProductCategoryId = id);
          debugPrint('productCategory => $id');
          // aquí luego filtras productos si corresponde
        },
        onMenuTap: () {},
        onUserTap: () {},
        onMoreTap: () {},
        onSearchChanged: (text) {
          setState(() => query = text);
          debugPrint('search: $text');
          // aquí luego filtras productos si corresponde
        },
        onSearchSubmitted: (text) {
          setState(() => query = text);
          debugPrint('submit: $text');
        },
      ),
      body: Center(
        child: Text(
          'POS Mobile Landscape\ncategory=$selectedProductCategoryId\nquery="$query"',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}