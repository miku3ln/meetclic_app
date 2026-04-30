import 'package:http/http.dart' as api;

import '../widgets/dialogs/moda_managerl.dart';

class ConfigApiService {
  Future<CustomerModelPosCurrent> fetchFinalConsumer() async {
 //   final response = await api.get('/consumer-final');
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
