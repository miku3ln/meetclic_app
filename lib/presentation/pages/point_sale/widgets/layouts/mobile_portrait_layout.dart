import 'package:flutter/material.dart';
import 'package:meetclic_app/presentation/pages/point_sale/widgets/layouts/tablet_landscape/pos_tablet_landscape_controller.dart';
import '../organisms/pos_header_bar.dart';

class PosMobilePortraitLayout extends StatelessWidget {
  final PosTabletLandscapeController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const PosMobilePortraitLayout({
    super.key,
    required this.controller,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PosHeaderBar(
        controllerMain: controller,
        productCategories: controller.browser.productCategories,
        // 👈 opcional mover
        selectedProductCategoryId:controller.browser.selectedProductCategoryId,
        onProductCategoryChanged: (id) {
          controller.browser.onProductCategoryChanged(id);
        },
        onSearchChanged: (text) {
          controller.setQuery(text);
        },
        onMenuTap: () => {},
        onSearchSubmitted: (text) {
          controller.setQuery(text);
        },

        onUserTap: (context, data) =>
            controller.ui.onUserTap(context, null, controller),

        onMoreTap: (context, data) =>
            controller.ui.onMoreTap(context, null, controller),
      ),

      body: Center(
        child: Text(
          'category=${controller.selectedProductCategoryId}\n'
          'query=${controller.query}',
        ),
      ),
    );
  }
}
