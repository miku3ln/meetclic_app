import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../domain/models/customer_model.dart';
import '../config/server_config.dart';
import '../../../domain/models/maritime_departure_model.dart';

class MaritimeDepartureResult {
  final bool success;
  final String message;
  final List data;

  MaritimeDepartureResult({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MaritimeDepartureResult.fromJson(Map<String, dynamic> json) {
    return MaritimeDepartureResult(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }

  factory MaritimeDepartureResult.empty() {
    return MaritimeDepartureResult(
      success: false,
      message: 'No existe Información!',
      data: [],
    );
  }
}

Map<String, String> splitFullName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')); // Divide por espacios

  if (parts.length >= 4) {
    return {
      'last_name': '${parts[0]} ${parts[1]}',
      'name': '${parts[2]} ${parts[3]}'
    };
  } else if (parts.length == 3) {
    return {
      'last_name': '${parts[0]} ${parts[1]}',
      'name': parts[2]
    };
  } else if (parts.length == 2) {
    return {
      'last_name': parts[0],
      'name': parts[1]
    };
  } else {
    return {
      'last_name': fullName,
      'name': fullName
    };
  }
}

class MaritimeDepartureService {
  final String baseUrl = '${ServerConfig.baseUrl}';

  Map<String, dynamic> buildMaritimeDeparturePayloadObject(
      List<CustomerModel> customers,
      MaritimeDepartureModel departureData,
      ) {

    String getPassengerTypeFromAge(int age) {
      if (age < 18) {
        return 'CHILD';
      } else {
        return 'ADULT';
      }
    }
    final customersData = customers.map((c) {
      final nameParts = splitFullName(c.fullName);
      return {
        "full_name": c.fullName,
        "last_name": nameParts['last_name'],
        "name": nameParts['name'],
        "type": getPassengerTypeFromAge(c.age),
        //"type": c.type,
        "age": c.age,
        "document_number": c.documentNumber,
      };
    }).toList();

    return {
      "data": {
        "MaritimeDepartures": departureData.toJson(),
        "Customers": customersData
      }
    };
  }


  Future<MaritimeDepartureResult> sendMaritimeDeparture(
      Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/saveMaritimeDepartureApi');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return MaritimeDepartureResult.fromJson(jsonData);
    } else {
      return MaritimeDepartureResult.empty();
    }
  }
  Future<DeparturesWithCustomersResult> getDeparturesWithCustomers({
    required int businessId,
    DateTime? from,
    DateTime? to
  }) async {

    final uri = Uri.parse('$baseUrl/getDeparturesWithCustomers').replace(
      queryParameters: {
        'businessId': businessId.toString(), // si es requerido en URL
        if (from != null) 'from': from.toIso8601String().substring(0, 10),
        if (to != null) 'to': to.toIso8601String().substring(0, 10),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },

    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return DeparturesWithCustomersResult.fromJson(jsonData);
    } else {
      return DeparturesWithCustomersResult.empty();
    }
  }
}

class SendMaritimeDepartureUseCase {
  final MaritimeDepartureService apiService;

  SendMaritimeDepartureUseCase(this.apiService);

  Future<SendMaritimeViewModel> execute(Map<String, dynamic> payload) async {
    final response = await apiService.sendMaritimeDeparture(payload);
    return MaritimeDepartureMapper.toViewModel(response);
  }
}

class SendMaritimeViewModel {


  final bool success;
  final String message;

  SendMaritimeViewModel({
    required this.success,
    required this.message,

  });
}
class DeparturesWithCustomersResult {
  final bool success;
  final String message;
  final List<MaritimeDepartureModel>  data;

  DeparturesWithCustomersResult({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DeparturesWithCustomersResult.fromJson(Map<String, dynamic> json) {
    return DeparturesWithCustomersResult(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((item) => MaritimeDepartureModel.fromJson(item))
          .toList(),
    );
  }

  factory DeparturesWithCustomersResult.empty() {
    return DeparturesWithCustomersResult(
      success: false,
      message: 'No existe Información!',
      data: [],
    );
  }
}
class MaritimeDepartureMapper {
  static SendMaritimeViewModel toViewModel(MaritimeDepartureResult response) {
    return SendMaritimeViewModel(
      success: response.success,
      message: response.message,
    );
  }
  static GetDeparturesWithCustomersViewModel toViewModelDeparturesWithCustomers(DeparturesWithCustomersResult response) {
    return GetDeparturesWithCustomersViewModel(
      success: response.success,
      message: response.message,
      data: response.data,

    );
  }
}


class GetDeparturesWithCustomersViewModel {


  final bool success;
  final String message;
  final List<MaritimeDepartureModel> data;

  GetDeparturesWithCustomersViewModel({
    required this.success,
    required this.message,
    required this.data,

  });
}
class GetDeparturesWithCustomersUseCase {
  final MaritimeDepartureService apiService;

  GetDeparturesWithCustomersUseCase(this.apiService);

  Future<GetDeparturesWithCustomersViewModel> execute({
    required int businessId,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await apiService.getDeparturesWithCustomers(
      businessId: businessId,
      from: from,
      to: to,
    );

    return MaritimeDepartureMapper.toViewModelDeparturesWithCustomers(response);
  }
}