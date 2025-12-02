import '../../infrastructure/services/customer_api_service.dart';
import '../mappers/cedula_mapper.dart';
import '../viewmodels/customer_cedula_viewmodel.dart';

class ValidateCedulaUseCase {
  final CustomerApiService apiService;

  ValidateCedulaUseCase(this.apiService);

  Future<CustomerCedulaViewModel> execute(String cedula) async {
    final response = await apiService.consultarCedula(cedula);
    return CedulaMapper.toViewModel(response);
  }
}
