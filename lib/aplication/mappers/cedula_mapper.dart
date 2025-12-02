import '../../domain/models/cedula_response_model.dart';
import '../viewmodels/customer_cedula_viewmodel.dart';

class CedulaMapper {
  static CustomerCedulaViewModel toViewModel(CedulaResponseModel response) {
    return CustomerCedulaViewModel(
      fullName: response.data.fullName,
      lastName: response.data.lastName,
      name: response.data.name,
      document: response.data.document,
      success: response.success,
      message: response.message,
    );
  }
}