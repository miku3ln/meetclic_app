
import '../models/user_login.dart';

import '../models/api_response_model.dart';

import '../repositories/user_repository.dart';


class LoginUseCase {
  final UserRepository repository;

  LoginUseCase(this.repository);

  Future<ApiResponseModel<Map<String, dynamic>>> call(
      UserLoginModel user,
      ) {
    return repository.loginUser(user);
  }
}