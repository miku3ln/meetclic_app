
import '../widgets/dialogs/customer/customer_manager.dart';

class ConfigApiService {
  Future<CustomerModelPosCurrent> fetchFinalConsumer() async {
    final mockData = {
      "id": "1",
      "name": "CONSUMIDOR FINAL",
      "email": 'consumidorfinal@trece.com',
      "phone": '099999999',
      "address": "",
      "city": null,
    };
    return CustomerModelPosCurrent.fromJson(mockData);
  }
}
