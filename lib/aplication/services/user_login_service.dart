import '../../domain/models/user_login.dart';
import '../../domain/usecases/login_user_usecase.dart';
import '../../domain/models/api_response_model.dart';
class UserLoginService {
  final LoginUseCase loginUseCase;

  UserLoginService(this.loginUseCase);
  Future<ApiResponseModel<Map<String, dynamic>>> register(UserLoginModel user) {
    return loginUseCase(user);
  }

}
