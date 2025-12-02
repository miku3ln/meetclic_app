import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../domain/models/user_registration_model.dart';
import '../../../domain/models/api_response_model.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/models/user_login.dart';

import '../../config/server_config.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../domain/models/user_registration_model.dart';
import '../../../domain/models/api_response_model.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/models/user_login.dart';

import '../../config/server_config.dart';
import '../../network/network_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../domain/models/user_registration_model.dart';
import '../../../domain/models/api_response_model.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/models/user_login.dart';

import '../../config/server_config.dart';
import '../../network/network_helper.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<ApiResponseModel<Map<String, dynamic>>> registerUser(UserRegistrationLoginModel user) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/auth/with/meetclic/register');

    return NetworkHelper.safeRequest<Map<String, dynamic>>(
      requestFunction: () {
        return http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(user.toJson()),
        );
      },
      parseData: (data) {
        if (data is String) {
          try {
            return jsonDecode(data) as Map<String, dynamic>;
          } catch (_) {
            return {};
          }
        } else if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {};
        }
      },
      emptyData: {},  // <- Siempre retornarás un mapa vacío en caso de error
    );
  }

  @override
  Future<ApiResponseModel<Map<String, dynamic>>> loginUser(UserLoginModel user) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/auth/with/meetclic/login');

    return NetworkHelper.safeRequest<Map<String, dynamic>>(
      requestFunction: () {
        return http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(user.toJson()),
        );
      },
      parseData: (data) {
        if (data is String) {
          try {
            return jsonDecode(data) as Map<String, dynamic>;
          } catch (_) {
            return {};
          }
        } else if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {};
        }
      },
      emptyData: {},  // <- Siempre mapa vacío en errores
    );
  }
}


class UserRepositoryImpl2 implements UserRepository {
  @override
  Future<ApiResponseModel<Map<String, dynamic>>> registerUser(UserRegistrationLoginModel user) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/auth/with/meetclic/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return ApiResponseModel.fromJson(
      jsonResponse,
          (data) {
        // El backend retorna data como un JSON STRING → Parsear a Map
        if (data is String) {
          try {
            return jsonDecode(data) as Map<String, dynamic>;
          } catch (e) {
            return {}; // Si no es un JSON válido, retornar mapa vacío
          }
        } else if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {};
        }
      },
    );
  }
  @override
  Future<ApiResponseModel<Map<String, dynamic>>> loginUser(UserLoginModel user) async {
    final url = Uri.parse('${ServerConfig.baseUrl}/auth/with/meetclic/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return ApiResponseModel.fromJson(
      jsonResponse,
          (data) {
        // El backend retorna data como un JSON STRING → Parsear a Map
        if (data is String) {
          try {
            return jsonDecode(data) as Map<String, dynamic>;
          } catch (e) {
            return {}; // Si no es un JSON válido, retornar mapa vacío
          }
        } else if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {};
        }
      },
    );
  }
}
