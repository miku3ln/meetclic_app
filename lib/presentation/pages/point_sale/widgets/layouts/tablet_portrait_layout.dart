import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../organisms/pos_header_bar.dart';
class PosTabletPortraitLayout extends StatelessWidget {
  final PosTabletLandscapeController controller;
  final scaffoldKey;

  const PosTabletPortraitLayout({
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
        productCategories: controller.productCategories,
        selectedProductCategoryId: controller.browser.selectedProductCategoryId,
        onProductCategoryChanged: controller.browser.onProductCategoryChanged,
        onMenuTap: () {},
        onUserTap: (context, data) =>
            controller.ui.onUserTap(context, null, controller),
        onMoreTap: (context, data) =>
            controller.ui.onMoreTap(context, null, controller),

        onSearchChanged: (text) {
          controller.setQuery(text); // ✅
        },

        onSearchSubmitted: (text) {
          controller.setQuery(text); // ✅
        },
      ),

      body: Center(
        child: Text(
          'POS Tablet Portrait\n'
              'category=${controller.selectedProductCategoryId}\n'
              'query="${controller.query}"',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}