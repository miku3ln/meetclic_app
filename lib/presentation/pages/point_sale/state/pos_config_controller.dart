
import '../repositories/config_repository.dart';
import '../widgets/dialogs/customer/customer_manager.dart';

class PosConfigController {
  final ConfigRepository repository;

  PosConfigController(this.repository);

  CustomerModelPosCurrent? finalConsumer;

  Future<void> loadInitialData() async {
    finalConsumer = await repository.getFinalConsumer();
  }
}