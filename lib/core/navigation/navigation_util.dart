import 'package:flutter/material.dart';

import 'route_names.dart';

class NavigationUtil {
  static void toBusinessDetails(BuildContext context, String businessId) {
    Navigator.pushNamed(context, '${RouteNames.businessDetails}/$businessId');
  }

  static void toProductDetails(BuildContext context, String productId) {
    Navigator.pushNamed(context, '${RouteNames.productDetails}/$productId');
  }

  static void goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.home,
      (route) => false,
    );
  }
}
