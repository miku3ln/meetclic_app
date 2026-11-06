import '../services/config_api_service.dart';
import '../widgets/dialogs/customer/customer_manager.dart';
import '../widgets/dialogs/moda_managerl.dart';

class ConfigRepository {
  final ConfigApiService api;

  ConfigRepository(this.api);

  CustomerModelPosCurrent? _finalConsumer;

  Future<CustomerModelPosCurrent> getFinalConsumer({
    bool forceRefresh = false,
  }) async {
    if (_finalConsumer != null && !forceRefresh) {
      return _finalConsumer!;
    }

    final data = await api.fetchFinalConsumer();
    _finalConsumer = data;

    return data;
  }
}

class CustomerServiceModal {

}