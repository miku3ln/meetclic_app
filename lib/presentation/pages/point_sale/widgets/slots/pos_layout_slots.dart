import 'package:flutter/material.dart';

class PosLayoutSlots {
  final PreferredSizeWidget? header;
  final Widget? left;
  final Widget? right;


  const PosLayoutSlots({
    this.header,
    this.left,
    this.right
  });
}
class LayoutLandSlots {
  final PreferredSizeWidget? header;
  final Widget? body;
  const LayoutLandSlots({
    this.header,
    this.body,
  });
}