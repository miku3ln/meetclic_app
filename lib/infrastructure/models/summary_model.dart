import 'package:meetclic_app/domain/entities/movement.dart';

class MovementAmountModel extends MovementAmount {
  // Constructor principal
  MovementAmountModel({
    required double totalInput,
    required double totalOutput,
    required double currentBalance,
  }) : super(
         totalInput: totalInput,
         totalOutput: totalOutput,
         currentBalance: currentBalance,
       );

  // Constructor de fábrica con validación y fallback
  factory MovementAmountModel.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) throw const FormatException("JSON nulo");

      return MovementAmountModel(
        totalInput: (json['totalInput'] as num).toDouble(),
        totalOutput: (json['totalOutput'] as num).toDouble(),
        currentBalance: (json['currentBalance'] as num).toDouble(),
      );
    } catch (e, stacktrace) {
      print('❌ Error al parsear MovementAmountModel: $e');
      // print(stacktrace); // Puedes descomentar para debug profundo
      return MovementAmountModel.empty();
    }
  }

  // Constructor vacío
  factory MovementAmountModel.empty() {
    return MovementAmountModel(
      totalInput: 0,
      totalOutput: 0,
      currentBalance: 0,
    );
  }

  // Método auxiliar para parseo seguro
  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class ReputationSummaryModel extends ReputationSummary {
  ReputationSummaryModel({required int total}) : super(total: total);

  factory ReputationSummaryModel.fromJson(Map<String, dynamic>? json) {
    try {
      return ReputationSummaryModel(total: (json?['total']) ?? 0);
    } catch (e) {
      print('❌ Error en ReputationSummaryModel: $e');
      return ReputationSummaryModel.empty();
    }
  }

  factory ReputationSummaryModel.empty() {
    return ReputationSummaryModel(total: 0);
  }
}

class TrophiesSummaryModel extends TrophiesSummary {
  TrophiesSummaryModel({required double total}) : super(total: total);

  factory TrophiesSummaryModel.fromJson(Map<String, dynamic>? json) {
    try {
      final totalValue = (json?['total'] as num?)?.toDouble() ?? 0.0;

      return TrophiesSummaryModel(total: totalValue);
    } catch (e) {
      print('❌ Error en TrophiesSummaryModel: $e');
      return TrophiesSummaryModel.empty();
    }
  }

  factory TrophiesSummaryModel.empty() {
    return TrophiesSummaryModel(total: 0);
  }
}

class VisitsSummaryModel extends VisitsSummary {
  VisitsSummaryModel({required int total}) : super(total: total);

  factory VisitsSummaryModel.fromJson(Map<String, dynamic>? json) {
    try {
      final totalValue = (json?['total'] as num?)?.toInt() ?? 0;

      return VisitsSummaryModel(total: totalValue);
    } catch (e) {
      print('❌ Error en VisitsSummaryModel: $e');
      return VisitsSummaryModel.empty();
    }
  }

  factory VisitsSummaryModel.empty() {
    return VisitsSummaryModel(total: 0);
  }
}

class RatingSummaryModel extends RatingSummary {
  RatingSummaryModel({
    required int positiveClients,
    required double averageStars,
    required double communityScore,
  }) : super(
         positiveClients: positiveClients,
         averageStars: averageStars,
         communityScore: communityScore,
       );

  factory RatingSummaryModel.fromJson(Map<String, dynamic>? json) {
    try {
      final positiveClients = (json?['positiveClients'] as num?)?.toInt() ?? 0;
      final averageStars = (json?['averageStars'] as num?)?.toDouble() ?? 0.0;
      final communityScore =
          (json?['communityScore'] as num?)?.toDouble() ?? 0.0;

      return RatingSummaryModel(
        positiveClients: positiveClients,
        averageStars: averageStars,
        communityScore: communityScore,
      );
    } catch (e) {
      print('❌ Error en RatingSummaryModel: $e');
      return RatingSummaryModel.empty();
    }
  }

  factory RatingSummaryModel.empty() {
    return RatingSummaryModel(
      positiveClients: 0,
      averageStars: 0,
      communityScore: 0,
    );
  }
}

class MovementSummaryModel extends MovementSummary {
  MovementSummaryModel({
    required MovementAmountModel yapitas,
    required MovementAmountModel yapitasPremium,
    required ReputationSummaryModel reputation,
    required TrophiesSummaryModel trophies,
    required VisitsSummaryModel visits,
    required RatingSummaryModel rating,
  }) : super(
         yapitas: yapitas,
         yapitasPremium: yapitasPremium,
         reputation: reputation,
         trophies: trophies,
         visits: visits,
         rating: rating,
       );

  factory MovementSummaryModel.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) throw const FormatException("JSON nulo");

      return MovementSummaryModel(
        yapitas: MovementAmountModel.fromJson(json['yapitas']),
        yapitasPremium: MovementAmountModel.fromJson(json['yapitasPremium']),
        reputation: ReputationSummaryModel.fromJson(json['reputation']),
        trophies: TrophiesSummaryModel.fromJson(json['trophies']),
        visits: VisitsSummaryModel.fromJson(json['visits']),
        rating: RatingSummaryModel.fromJson(json['rating']),
      );
    } catch (e) {
      print('❌ Error al parsear MovementSummaryModel: $e');
      return MovementSummaryModel.empty();
    }
  }

  factory MovementSummaryModel.empty() {
    return MovementSummaryModel(
      yapitas: MovementAmountModel.empty(),
      yapitasPremium: MovementAmountModel.empty(),
      reputation: ReputationSummaryModel.empty(),
      trophies: TrophiesSummaryModel.empty(),
      visits: VisitsSummaryModel.empty(),
      rating: RatingSummaryModel.empty(),
    );
  }
}
