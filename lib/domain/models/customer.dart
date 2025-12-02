class Customer {
  final String identificationDocument;
  final int peopleTypeIdentificationId;
  final int peopleId;
  final String businessName;
  final String businessReason;
  final int rucTypeId;
  final int id;

  Customer({
    required this.identificationDocument,
    required this.peopleTypeIdentificationId,
    required this.peopleId,
    required this.businessName,
    required this.businessReason,
    required this.rucTypeId,
    required this.id,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      identificationDocument: json['identification_document'],
      peopleTypeIdentificationId: json['people_type_identification_id'],
      peopleId: json['people_id'],
      businessName: json['business_name'] ?? '',
      businessReason: json['business_reason'] ?? '',
      rucTypeId: json['ruc_type_id'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identification_document': identificationDocument,
      'people_type_identification_id': peopleTypeIdentificationId,
      'people_id': peopleId,
      'business_name': businessName,
      'business_reason': businessReason,
      'ruc_type_id': rucTypeId,
      'id': id,
    };
  }

}
