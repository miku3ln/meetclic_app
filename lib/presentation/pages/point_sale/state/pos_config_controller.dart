
import '../repositories/config_repository.dart';
import '../services/config_api_service.dart';
import '../widgets/dialogs/moda_managerl.dart';

class PosConfigController {
  final ConfigRepository repository;

  PosConfigController(this.repository);

  CustomerModelPosCurrent? finalConsumer;

  Future<void> loadInitialData() async {
    finalConsumer = await repository.getFinalConsumer();
  }
}