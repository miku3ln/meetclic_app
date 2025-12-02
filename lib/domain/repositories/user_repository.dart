import '../models/user_registration_model.dart';
import '../models/api_response_model.dart';
import '../models/user_login.dart';


abstract class UserRepository {
  Future<ApiResponseModel<Map<String, dynamic>>> registerUser(UserRegistrationLoginModel user);
  Future<ApiResponseModel<Map<String, dynamic>>> loginUser(UserLoginModel user);

}
