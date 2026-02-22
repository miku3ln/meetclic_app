import 'package:flutter/material.dart';
import '../organisms/pos_header_bar.dart';
import '../models/pos_product_item.dart'; // PosCategoryItem
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';

class PosTabletPortraitLayout extends StatefulWidget {
  const PosTabletPortraitLayout({super.key});

  @override
  State<PosTabletPortraitLayout> createState() =>
      _PosTabletPortraitLayoutState();
}

class _PosTabletPortraitLayoutState extends State<PosTabletPortraitLayout> {
  late final List<PosCategoryItem> productCategories;
  String? selectedProductCategoryId;

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
        },
        onMenuTap: () {},
        onUserTap: () {},
        onMoreTap: () {},
        onSearchChanged: (text) {
          setState(() => query = text);
          debugPrint('search: $text');
        },
        onSearchSubmitted: (text) {
          setState(() => query = text);
          debugPrint('submit: $text');
        },
      ),
      body: Center(
        child: Text(
          'POS Tablet Portrait\ncategory=$selectedProductCategoryId\nquery="$query"',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}