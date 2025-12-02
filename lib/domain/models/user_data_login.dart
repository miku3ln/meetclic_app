import 'dart:convert';

import 'package:meetclic_app/infrastructure/models/summary_model.dart';

class UserDataLogin {
  final int userId;
  final String userName;
  final String email;
  final String userStatus;
  final int roleId;
  final String roleName;
  final String? username;
  final String? avatar;
  final int? customerId;
  final String? identificationDocument;
  final String? businessName;
  final String? businessReason;
  final int? hasRepresentative;
  final String? representativeFullname;
  final int? rucTypeId;
  final String? rucTypeName;
  final int? peopleTypeId;
  final String? peopleTypeName;
  final String? peopleTypeCode;
  final int? personId;
  final String? lastName;
  final String? personName;
  final String? birthdate;
  final int? age;
  final int? gender;
  final String accessToken;
  MovementSummaryModel? summary;
  UserDataLogin({
    required this.userId,
    required this.userName,
    required this.email,
    required this.userStatus,
    required this.roleId,
    required this.roleName,
    this.username,
    this.avatar,
    this.customerId,
    this.identificationDocument,
    this.businessName,
    this.businessReason,
    this.hasRepresentative,
    this.representativeFullname,
    this.rucTypeId,
    this.rucTypeName,
    this.peopleTypeId,
    this.peopleTypeName,
    this.peopleTypeCode,
    this.personId,
    this.lastName,
    this.personName,
    this.birthdate,
    this.age,
    this.gender,
    this.summary,
    required this.accessToken,
  });

  factory UserDataLogin.fromJson(Map<String, dynamic> json) {
    const String movementSummaryJson = '''
{
  "yapitas": {
    "totalInput": 0,
    "totalOutput": 0,
    "currentBalance": 0
  },
  "yapitasPremium": {
    "totalInput": 0,
    "totalOutput": 0,
    "currentBalance": 0
  },
  "reputation": {
    "total": 0
  },
   "trophies": {
    "total": 0
  },
   "visits": {
    "total": 0
  },
   "rating": {
    "positiveClients": 0,
    "averageStars": 0,
    "communityScore": 0}
}
''';
    final Map<String, dynamic> jsonDataSummary = jsonDecode(
      movementSummaryJson,
    );
    var userData = json;
    return UserDataLogin(
      userId: userData['user_id'] ?? 0,
      accessToken: userData['access_token'] ?? '',
      userName: userData['user_name'] ?? '',
      email: userData['email'] ?? '',
      userStatus: userData['user_status'] ?? '',
      roleId: userData['role_id'] ?? 0,
      roleName: userData['role_name'] ?? '',
      username: userData['username'],
      avatar: userData['avatar'],
      customerId: userData['customer_id'],
      identificationDocument: userData['identification_document'],
      businessName: userData['business_name'],
      businessReason: userData['business_reason'],
      hasRepresentative: userData['has_representative'],
      representativeFullname: userData['representative_fullname'],
      rucTypeId: userData['ruc_type_id'],
      rucTypeName: userData['ruc_type_name'],
      peopleTypeId: userData['people_type_id'],
      peopleTypeName: userData['people_type_name'],
      peopleTypeCode: userData['people_type_code'] ?? 'N',
      personId: userData['person_id'],
      lastName: userData['last_name'],
      personName: userData['person_name'],
      birthdate: userData['birthdate'],
      age: userData['age'],
      gender: userData['gender'],
      summary: userData['summary'] != null
          ? MovementSummaryModel.fromJson(userData['summary'])
          : MovementSummaryModel.fromJson(jsonDataSummary),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'email': email,
      'user_status': userStatus,
      'role_id': roleId,
      'role_name': roleName,
      'username': username,
      'avatar': avatar,
      'customer_id': customerId,
      'identification_document': identificationDocument,
      'business_name': businessName,
      'business_reason': businessReason,
      'has_representative': hasRepresentative,
      'representative_fullname': representativeFullname,
      'ruc_type_id': rucTypeId,
      'ruc_type_name': rucTypeName,
      'people_type_id': peopleTypeId,
      'people_type_name': peopleTypeName,
      'people_type_code': peopleTypeCode,
      'person_id': personId,
      'last_name': lastName,
      'person_name': personName,
      'birthdate': birthdate,
      'age': age,
      'gender': gender,
      'accessToken': accessToken,
      'summary': summary?.toJson(),
    };
  }
}
