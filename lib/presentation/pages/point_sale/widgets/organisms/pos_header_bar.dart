import 'package:flutter/material.dart';

import '../../helpers/pos_responsive.dart';
import '../layouts/pos_header_default.dart';
import '../layouts/pos_header_mobile_portrait.dart';
import '../layouts/pos_main_controller.dart';
import '../models/pos_product_item.dart';



class PosHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  // ✅ (1) Product categories (dropdown)
  final List<PosCategoryItem> productCategories;
  final String? selectedProductCategoryId;
  final ValueChanged<String?> onProductCategoryChanged;

  // top actions
  final VoidCallback onMenuTap;
  final void Function(BuildContext context, dynamic data) onUserTap;
  final void Function(BuildContext context, dynamic data)  onMoreTap;

  // ✅ (3) search
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final PosMainController controllerMain;
  const PosHeaderBar({
    super.key,
    required this.productCategories,
    required this.selectedProductCategoryId,
    required this.onProductCategoryChanged,
    required this.onMenuTap,
    required this.onUserTap,
    required this.onMoreTap,
    this.onSearchChanged,
    this.onSearchSubmitted,
    required  this.controllerMain,

  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final showMobilePortraitHeader = PosResponsive.isMobile(context);

    if (showMobilePortraitHeader) {
      return PosHeaderMobilePortraitLayout(
        productCategories: productCategories,
        selectedProductCategoryId: selectedProductCategoryId,
        onMenuTap: onMenuTap,
        onProductCategoryChanged: onProductCategoryChanged,
        onSearchChanged: onSearchChanged,
        onSearchSubmitted: onSearchSubmitted,
        onUserTap: onUserTap,
        onMoreTap: onMoreTap,
      );
    }

    return PosHeaderDefaultLayout(
      controllerMain: controllerMain,
      productCategories: productCategories,
      selectedProductCategoryId: selectedProductCategoryId,
      onMenuTap: onMenuTap,
      onProductCategoryChanged: onProductCategoryChanged,
      onSearchChanged: onSearchChanged,
      onSearchSubmitted: onSearchSubmitted,
      onUserTap: onUserTap,
      onMoreTap: onMoreTap,
    );
  }
}