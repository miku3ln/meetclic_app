// lib/shared/constants/api_config.dart

class ApiConfig {
  static const String baseUrl = 'http://localhost/meetclickmanager/api/';

  static Uri endpoint(String path) {
    return Uri.parse('$baseUrl$path');
  }
}
