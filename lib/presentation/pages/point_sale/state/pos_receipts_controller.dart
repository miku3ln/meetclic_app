import 'package:flutter/foundation.dart';

import '../../../../shared/pagination_response.dart';



class PosReceiptsController extends ChangeNotifier {
  GenericListItem<Map<String, dynamic>>? _selectedReceipt;

  GenericListItem<Map<String, dynamic>>? get selectedReceipt =>
      _selectedReceipt;

  bool get hasSelection => _selectedReceipt != null;

  String get section {
    final data = _selectedReceipt?.data ?? {};
    return data['ticketCode']?.toString() ?? '';
  }

  void setSelectedReceipt(
      GenericListItem<Map<String, dynamic>> receipt,
      ) {
    if (_selectedReceipt?.id == receipt.id) {
      return;
    }

    _selectedReceipt = receipt;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedReceipt == null) {
      return;
    }

    _selectedReceipt = null;
    notifyListeners();
  }
}
