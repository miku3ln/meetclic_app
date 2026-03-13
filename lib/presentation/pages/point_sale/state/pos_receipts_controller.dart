import 'package:flutter/foundation.dart';

import '../../../../shared/pagination_response.dart';



class PosReceiptsController extends ChangeNotifier {
  GenericListItem<Map<String, dynamic>>? _selectedReceipt;

  GenericListItem<Map<String, dynamic>>? get selectedReceipt => _selectedReceipt;

  String get section => _selectedReceipt?.description ?? '-1';

  bool get hasSelection => _selectedReceipt != null;

  void setSelectedReceipt(GenericListItem<Map<String, dynamic>> receipt) {
    _selectedReceipt = receipt;
    notifyListeners();
  }

  void clearSelection() {
    _selectedReceipt = null;
    notifyListeners();
  }
}
