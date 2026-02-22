import 'package:flutter/material.dart';

class PosResponsive {
  static const double tabletBreakpoint = 600;

  static bool isTablet(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    return shortest >= tabletBreakpoint;
  }

  static bool isMobile(BuildContext context) => !isTablet(context);

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isMobilePortrait(BuildContext context) =>
      isMobile(context) && isPortrait(context);
}