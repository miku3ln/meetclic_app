import 'package:flutter/material.dart';
import '../shared/responsive/device_gesture_observer.dart';

import '../pages/point_sale/widgets/layouts/mobile_portrait_layout.dart';
import '../pages/point_sale/widgets/layouts/mobile_landscape_layout.dart';
import '../pages/point_sale/widgets/layouts/tablet_portrait_layout.dart';
import '../pages/point_sale/widgets/layouts/tablet_landscape_layout.dart';

class PointSalePage extends StatelessWidget {
  const PointSalePage({super.key});

  @override
  Widget build(BuildContext context) {
    final device = DeviceGestureObserver.snapshotOf(context);

    return DeviceGestureObserver(
      onEvent: (d, e) {
        debugPrint('DEVICE => $d');
        debugPrint('EVENT  => $e');
      },
      child: _buildByLayout(device.layoutType),
    );
  }

  Widget _buildByLayout(LayoutType layout) {
    switch (layout) {
      case LayoutType.mobilePortrait:
        return const PosMobilePortraitLayout();
      case LayoutType.mobileLandscape:
        return const PosMobileLandscapeLayout();
      case LayoutType.tabletPortrait:
        return const PosTabletPortraitLayout();
      case LayoutType.tabletLandscape:
        return const PosTabletLandscapeLayout();
    }
  }
}
