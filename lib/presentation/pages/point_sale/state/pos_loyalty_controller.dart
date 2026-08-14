import 'package:flutter/foundation.dart';

import '../widgets/sections/pos_layouts_utils.dart';

enum PosLoyaltySection { dashboard, cupon, gamification, tracking }

class PosLoyaltyController
    extends PosSectionController<PosLoyaltySection> {
  PosLoyaltyController()
      : super(PosLoyaltySection.dashboard);


  String get sectionTitle {
    switch (section) {
      case PosLoyaltySection.dashboard:
        return 'Dashboard';
      case PosLoyaltySection.cupon:
        return 'Cupones';
      case PosLoyaltySection.gamification:
        return 'Gamificacion';
      case PosLoyaltySection.tracking:
        return 'Canales';
    }
  }
}
