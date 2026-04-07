import '../services/config_api_service.dart';
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
  Future<List<CustomerModelPosCurrent>> fetchCustomers() async {
    /// Simula delay de API
    await Future.delayed(const Duration(seconds: 2));

    /// Data mock (simulación backend)
    return [
      CustomerModelPosCurrent(
        id: "1",
        name: "Juan Pérez",
        email: "juan@mail.com",
        phone: "0999999999",
        city: "Quito",
      ),
      CustomerModelPosCurrent(
        id: "2",
        name: "María López",
        email: "maria@mail.com",
        phone: "0888888888",
        city: "Otavalo",
      ),
      CustomerModelPosCurrent(
        id: "3",
        name: "Carlos Andrade",
        email: "carlos@mail.com",
        phone: "0777777777",
        city: "Ibarra",
      ),
    ];
  }
}