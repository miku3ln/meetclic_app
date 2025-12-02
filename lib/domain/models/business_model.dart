import 'dart:convert';

import 'package:meetclic_app/domain/models/business_day.dart';
import 'package:meetclic_app/domain/models/social_network.dart';
import 'package:meetclic_app/infrastructure/models/summary_model.dart';

class BusinessModel {
  final int id;
  final String title;
  final String description;
  final String businessName;
  final String email;
  final String phoneValue;
  final String pageUrl;
  final String street1;
  final String street2;
  final double streetLat;
  final double streetLng;
  final String status;
  final double qualification;
  final int businessSubcategoryId;
  final String subcategoryName;
  final String fiscalPosition;
  final double distance;
  final String distanceKmText;
  final String sourceLogo;
  MovementSummaryModel? summary;
  List<BusinessDay>? schedulingData;
  List<SocialNetwork>? socialNetworksData;

  BusinessModel({
    required this.id,
    required this.title,
    required this.description,
    required this.businessName,
    required this.email,
    required this.phoneValue,
    required this.pageUrl,
    required this.street1,
    required this.street2,
    required this.streetLat,
    required this.streetLng,
    required this.status,
    required this.qualification,
    required this.businessSubcategoryId,
    required this.subcategoryName,
    required this.fiscalPosition,
    required this.distance,
    required this.distanceKmText,
    required this.sourceLogo,
    required this.summary,
    this.schedulingData,
    this.socialNetworksData,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
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
    var sourceLogo = json['source'];
    final Map<String, dynamic> jsonDataSummary = jsonDecode(
      movementSummaryJson,
    );
    var summaryCurrent = json['summary'] == null
        ? jsonDataSummary
        : json['summary'];
    var schedules = json['schedules'];
    var socialNetworksDataJson =
        json['socialNetworksData']; //TODO INVIOCAR fromMap
    List<SocialNetwork> socialNetworksData = [];
    if (socialNetworksDataJson != null) {
      socialNetworksData = SocialNetwork.fromMap(socialNetworksDataJson);
    }

    var summary = MovementSummaryModel.fromJson(summaryCurrent);
    List<BusinessDay> schedulingData = [];
    if (schedules != null) {
      schedulingData = (schedules as List<dynamic>)
          .map((e) => BusinessDay.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return BusinessModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      businessName: json['business_name'] ?? '',
      email: json['email'] ?? '',
      phoneValue: json['phone_value'] ?? '',
      pageUrl: json['page_url'] ?? '',
      street1: json['street_1'] ?? '',
      street2: json['street_2'] ?? '',
      streetLat: double.parse(json['street_lat'].toString()),
      streetLng: double.parse(json['street_lng'].toString()),
      status: json['status'] ?? '',
      qualification: double.tryParse(json['qualification'].toString()) ?? 0.0,
      businessSubcategoryId: json['business_subcategories_id'],
      subcategoryName: json['subcategory_name'] ?? '',
      fiscalPosition: json['fiscal_position'] ?? '',
      distance: double.tryParse(json['distance'].toString()) ?? 0.0,
      distanceKmText: json['distance_km'] ?? '',
      sourceLogo: sourceLogo,
      summary: summary,
      schedulingData: schedulingData,
      socialNetworksData: socialNetworksData,
    );
  }
  factory BusinessModel.empty([int businessId = 1]) {
    return BusinessModel(
      id: businessId,
      title: '',
      description: '',
      businessName: '',
      email: '',
      phoneValue: '',
      pageUrl: '',
      street1: '',
      street2: '',
      streetLat: 0.0,
      streetLng: 0.0,
      status: '',
      qualification: 0.0,
      businessSubcategoryId: 0,
      subcategoryName: '',
      fiscalPosition: '',
      distance: 0.0,
      distanceKmText: '',
      sourceLogo: '',
      summary: MovementSummaryModel.fromJson({
        "yapitas": {"totalInput": 0, "totalOutput": 0, "currentBalance": 0},
        "yapitasPremium": {
          "totalInput": 0,
          "totalOutput": 0,
          "currentBalance": 0,
        },
        "reputation": {"total": 0},
        "trophies": {"total": 0},
        "visits": {"total": 0},
        "rating": {
          "positiveClients": 0,
          "averageStars": 0,
          "communityScore": 0,
        },
      }),
      schedulingData: [],
      socialNetworksData: [],
    );
  }
}
