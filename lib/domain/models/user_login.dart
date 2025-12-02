
class UserLoginModel {
  final String email;
  final String password;

  UserLoginModel({
    required this.email,
    required this.password,

  });
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,

  };

}
