import '../../../../domain/models/customer_model.dart';

class MaritimeDepartureModel {
  final int businessId;
  final int userId;
  final int userManagementId;
  final String arrivalTime;
  final String responsibleName;
  final List<CustomerModel>? customers;
  MaritimeDepartureModel({
    required this.businessId,
    required this.userId,
    required this.userManagementId,
    required this.arrivalTime,
    required this.responsibleName,
     this.customers,

  });

  factory MaritimeDepartureModel.fromJson(Map<String, dynamic> json) {
    return MaritimeDepartureModel(
      businessId: json['business_id'],
      userId: json['user_id'],
      userManagementId: json['user_management_id'] ?? 1,
      arrivalTime: json['arrival_time'],
      responsibleName: json['responsible_name'],
      customers: (json['customers'] as List<dynamic>?)
          ?.map((e) => CustomerModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "business_id": businessId,
      "user_id": userId,
      "user_management_id": userManagementId,
      "arrival_time": arrivalTime,
      "responsible_name": responsibleName,
    };
  }
  factory MaritimeDepartureModel.empty() {
    return MaritimeDepartureModel(
      businessId: -1,
      userId: -1,
      userManagementId: -1,
      arrivalTime: '',
      responsibleName: '',

    );
  }
  factory MaritimeDepartureModel.getSave() {
    return MaritimeDepartureModel(
      businessId: -1,
      userId: -1,
      userManagementId: -1,
      arrivalTime: '',
      responsibleName: '',

    );
  }
}
