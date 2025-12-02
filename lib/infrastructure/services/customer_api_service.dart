// lib/infrastructure/services/customer_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/cedula_response_model.dart';
import '../config/server_config.dart';
class CustomerApiService {
  final String baseUrl = '${ServerConfig.baseUrl}';

  Future<CedulaResponseModel> consultarCedula(String cedula) async {
    final uri = Uri.parse('$baseUrl/api-information/consultar-cedula-legal?cedula=$cedula');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return CedulaResponseModel.fromJson(jsonData);
    } else {


      return  CedulaResponseModel.empty();
    }
  }
}
