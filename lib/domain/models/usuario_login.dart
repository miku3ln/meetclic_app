
import 'customer.dart';
import 'user.dart';
import 'customer_by_profile.dart';

class UsuarioLogin {
  final Customer customer;
  final User user;
  final CustomerByProfile? customerByProfile; // Puede ser null
  final String accessToken;

  UsuarioLogin({
    required this.customer,
    required this.user,
    required this.customerByProfile,
    required this.accessToken,
  });

  factory UsuarioLogin.fromJson(Map<String, dynamic> json) {
    final information = json['information'];
    return UsuarioLogin(
      customer: Customer.fromJson(information['Customer']),
      user: User.fromJson(information['User']),
      customerByProfile: information['CustomerByProfile'] != null
          ? CustomerByProfile.fromJson(information['CustomerByProfile'])
          : null,
      accessToken: json['access_token'],
    );
  }
}
