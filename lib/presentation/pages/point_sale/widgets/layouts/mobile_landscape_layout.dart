import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../../../../../shared/controllers/app_controller.dart';
import '../organisms/pos_header_bar.dart';
import '../models/pos_product_item.dart'; // PosCategoryItem
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import 'package:provider/provider.dart';

class PosMobileLandscapeLayout extends StatefulWidget {

  const PosMobileLandscapeLayout({super.key,


  });

  @override
  State<PosMobileLandscapeLayout> createState() =>
      _PosMobileLandscapeLayoutState();
}

class _PosMobileLandscapeLayoutState extends State<PosMobileLandscapeLayout> {
  late final PosTabletLandscapeController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // ✅

  // ✅ (1) dropdown: product categories
  late final List<PosCategoryItem> productCategories;
  String? selectedProductCategoryId;

  // ✅ (3) search
  String query = '';

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    controller = PosTabletLandscapeController(app: app)..addListener(_onChanged);
    productCategories = PosTabletLandscapeFixtures.getCategoriesData();
    selectedProductCategoryId = productCategories.isNotEmpty
        ? productCategories.first.id
        : null;
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
        controllerMain: controller,
        productCategories: productCategories,
        selectedProductCategoryId: selectedProductCategoryId,
        onProductCategoryChanged: (id) {
          setState(() => selectedProductCategoryId = id);
          debugPrint('productCategory => $id');
          // aquí luego filtras productos si corresponde
        },
        onMenuTap: () {},
        onUserTap: (BuildContext context, dynamic data) {
          print('mobile_land_scape onUserTap ');
        },
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
