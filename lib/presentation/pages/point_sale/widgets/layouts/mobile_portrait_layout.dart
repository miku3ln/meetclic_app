import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../organisms/pos_header_bar.dart';
import '../models/pos_product_item.dart'; // PosCategoryItem
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';

class PosMobilePortraitLayout extends StatefulWidget {


  const PosMobilePortraitLayout({super.key,



  });

  @override
  State<PosMobilePortraitLayout> createState() =>
      _PosMobilePortraitLayoutState();
}

class _PosMobilePortraitLayoutState extends State<PosMobilePortraitLayout> {
  late final List<PosCategoryItem> productCategories;
  String? selectedProductCategoryId;
  late final PosTabletLandscapeController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // ✅

  String query = '';

  @override
  void initState() {
    super.initState();
    productCategories = PosTabletLandscapeFixtures.getCategoriesData();
    selectedProductCategoryId =
    productCategories.isNotEmpty ? productCategories.first.id : null;
  }
  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }
  @override
  void dispose() {
    controller.removeListener(_onChanged);
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PosHeaderBar(
        controllerMain:controller ,

        productCategories: productCategories,
        selectedProductCategoryId: selectedProductCategoryId,
        onProductCategoryChanged: (id) {
          setState(() => selectedProductCategoryId = id);
          debugPrint('productCategory => $id');
        },
        onMenuTap: () {},
        onUserTap: (BuildContext context, dynamic data) {
          print('mobile_portrait onUserTap ');

        },
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
          'POS Mobile Portrait\ncategory=$selectedProductCategoryId\nquery="$query"',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}