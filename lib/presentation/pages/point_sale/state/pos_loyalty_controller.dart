import 'package:flutter/foundation.dart';

enum PosLoyaltySection { dashboard, cupon, gamification, tracking }

class PosLoyaltyController extends ChangeNotifier {
  PosLoyaltySection _section = PosLoyaltySection.dashboard;

  PosLoyaltySection get section => _section;

  void setSection(PosLoyaltySection value) {
    if (_section == value) return;
    _section = value;
    notifyListeners();
  }

  String get sectionTitle {
    switch (_section) {
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
