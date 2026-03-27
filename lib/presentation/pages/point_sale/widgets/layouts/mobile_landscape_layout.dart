import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../../../../../shared/controllers/app_controller.dart';
import '../dialogs/pos_open_shift_dialog.dart';
import '../organisms/pos_header_bar.dart';
import '../models/pos_product_item.dart'; // PosCategoryItem
import '../layouts/tablet_landscape/pos_tablet_landscape_fixtures.dart';
import 'package:provider/provider.dart';
class PosMobileLandscapeLayout extends StatelessWidget {
  final PosTabletLandscapeController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const PosMobileLandscapeLayout({
    super.key,
    required this.controller,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      appBar: PosHeaderBar(
        controllerMain: controller,

        // ✅ TODO DESDE EL CONTROLLER
        productCategories: controller.productCategories,
        selectedProductCategoryId: controller.selectedProductCategoryId,

        onProductCategoryChanged: (id) {
          controller.setProductCategory(id!); // 🔥
        },

        onMenuTap: () {},

        onUserTap: (context, data) =>
            controller.ui.onUserTap(context, null, controller),

        onMoreTap: (context, data) =>
            controller.ui.onMoreTap(context, null, controller),

        onSearchChanged: (text) {
          controller.setQuery(text); // 🔥
        },

        onSearchSubmitted: (text) {
          controller.setQuery(text); // 🔥
        },
      ),

      body: Center(
        child: Text(
          'POS Mobile Landscape\n'
              'category=${controller.selectedProductCategoryId}\n'
              'query="${controller.query}"',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}