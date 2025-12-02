import '../../domain/models/user_registration_model.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/models/api_response_model.dart';
class UserService {
  final RegisterUserUseCase registerUserUseCase;


  UserService(this.registerUserUseCase);

  Future<ApiResponseModel<Map<String, dynamic>>> register(UserRegistrationLoginModel user) {
    return registerUserUseCase(user);
  }

}
