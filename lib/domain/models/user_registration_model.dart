class UserRegistrationLoginModel {
  final String email;
  final String password;
  final String name;
  final String last_name;
  final DateTime birthdate;

  UserRegistrationLoginModel({
    required this.email,
    required this.password,
    required this.name,
    required this.last_name,
    required this.birthdate,
  });
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
    'last_name': last_name,
    'birthdate': birthdate.toIso8601String(),
  };

}
