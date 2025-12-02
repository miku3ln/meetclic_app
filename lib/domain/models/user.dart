class User {
  final String name;
  final String email;
  final String provider;
  final String updatedAt;
  final String createdAt;
  final int id;
  final String apiToken;

  User({
    required this.name,
    required this.email,
    required this.provider,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.apiToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      provider: json['provider'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
      apiToken: json['api_token'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'provider': provider,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
      'api_token': apiToken,
    };
  }
}
