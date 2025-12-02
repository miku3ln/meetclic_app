import '../models/user_registration_model.dart';
import '../models/api_response_model.dart';

import '../repositories/user_repository.dart';

class RegisterUserUseCase {
  final UserRepository repository;

  RegisterUserUseCase(this.repository);

  Future<ApiResponseModel<Map<String, dynamic>>> call(
      UserRegistrationLoginModel user,
  ) {
    return repository.registerUser(user);
  }
}
