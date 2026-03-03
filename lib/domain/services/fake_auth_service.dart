import 'dart:async';


import 'package:meetclic_app/infrastructure/models/summary_model.dart';

import '../models/user_data_login.dart';

class FakeAuthService {
  static const String _user = 'admin';
  static const String _pass = '123456789@';

  Future<UserDataLogin> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700)); // ⏳ simula red

    if (email.trim() != _user || password != _pass) {
      throw Exception('Credenciales inválidas (usa admin / 123456789@)');
    }

    // ✅ Summary con datos para que se vea en MenuTabUpController
    final summary = MovementSummaryModel(
      yapitas: MovementAmountModel(
        totalInput: 1200,
        totalOutput: 200,
        currentBalance: 1000,
      ),
      yapitasPremium: MovementAmountModel(
        totalInput: 50,
        totalOutput: 10,
        currentBalance: 40,
      ),
      reputation: ReputationSummaryModel(total: 77),
      trophies: TrophiesSummaryModel(total: 12),
      visits: VisitsSummaryModel(total: 340),
      rating: RatingSummaryModel(
        positiveClients: 25,
        averageStars: 4.8,
        communityScore: 93.5,
      ),
    );

    return UserDataLogin(
      userId: 1,
      userName: 'Administrador',
      email: 'admin',
      userStatus: 'ACTIVE',
      roleId: 1,
      roleName: 'ADMIN',
      accessToken: 'fake-token-admin',

      // opcionales
      username: 'admin',
      avatar: null,
      customerId: null,
      identificationDocument: null,
      businessName: null,
      businessReason: null,
      hasRepresentative: null,
      representativeFullname: null,
      rucTypeId: null,
      rucTypeName: null,
      peopleTypeId: null,
      peopleTypeName: null,
      peopleTypeCode: 'N',
      personId: 1,
      lastName: 'Admin',
      personName: 'Admin',
      birthdate: '1990-01-01',
      age: 35,
      gender: 1,

      summary: summary,
    );
  }
}