class CedulaResponseModel {
  final bool success;
  final String message;
  final CedulaDataModel data;

  CedulaResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CedulaResponseModel.fromJson(Map<String, dynamic> json) {
    return CedulaResponseModel(
      success: json['success'],
      message: json['message'],
      data: CedulaDataModel.fromJson(json['data']),
    );
  }
  factory CedulaResponseModel.empty() {
    return CedulaResponseModel(
      success: false,
      message: 'No existe Información!',
      data: CedulaDataModel.empty(),
    );
  }
}

class CedulaDataModel {
  final String fullName;
  final String lastName;
  final String name;
  final String document;

  CedulaDataModel({
    required this.fullName,
    required this.lastName,
    required this.name,
    required this.document,
  });
  factory CedulaDataModel.empty() {
    return CedulaDataModel(
      fullName: '',
      lastName: '',
      name: '',
      document: '',
    );
  }
  factory CedulaDataModel.fromJson(Map<String, dynamic> json) {
    return CedulaDataModel(
      fullName: json['full_name'] ?? '',
      lastName: json['last_name'] ?? '',
      name: json['name'] ?? '',
      document: json['document'] ?? '',
    );
  }
}
