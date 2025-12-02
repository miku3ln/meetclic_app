class Movement {
  final int id;
  final DateTime dateRegister;
  final String description;
  final String inputMovementName;
  final int inputMovementValue;
  final int tipoTransactionValue;
  final String tipoTransactionName;
  final int amount;
  final int typeMoneyValue;
  final String typeMoneyName;
  final String processName;
  final String sourceProcess;
  final String activityName;

  Movement({
    required this.id,
    required this.dateRegister,
    required this.description,
    required this.inputMovementName,
    required this.inputMovementValue,
    required this.tipoTransactionValue,
    required this.tipoTransactionName,
    required this.amount,
    required this.typeMoneyValue,
    required this.typeMoneyName,
    required this.processName,
    required this.sourceProcess,
    required this.activityName,
  });
}

class MovementSummary {
  final MovementAmount yapitas;
  final MovementAmount yapitasPremium;
  final ReputationSummary reputation;
  final TrophiesSummary trophies;
  final VisitsSummary visits;
  final RatingSummary rating;

  MovementSummary({
    required this.yapitas,
    required this.yapitasPremium,
    required this.reputation,
    required this.trophies,
    required this.visits,
    required this.rating,


  });
  Map<String, dynamic> toJson() {
    return {
      'yapitas': yapitas.toJson(),
      'yapitasPremium': yapitasPremium.toJson(),
      'reputation': reputation.toJson(),
      'trophies': trophies.toJson(),
      'visits': visits.toJson(),
      'rating': visits.toJson(),

    };
  }
}

class MovementAmount {
  final double totalInput;
  final double totalOutput;
  final double currentBalance;

  MovementAmount({
    required this.totalInput,
    required this.totalOutput,
    required this.currentBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalInput': totalInput,
      'totalOutput': totalOutput,
      'currentBalance': currentBalance,
    };
  }
}

class ReputationSummary {
  final int total;

  ReputationSummary({required this.total});
  Map<String, dynamic> toJson() {
    return {
      'total': total,
    };
  }
}
class TrophiesSummary {
  final double total;

  TrophiesSummary({required this.total});
  Map<String, dynamic> toJson() {
    return {
      'total': total,
    };
  }
}
class VisitsSummary {
  final int total;

  VisitsSummary({required this.total});
  Map<String, dynamic> toJson() {
    return {
      'total': total,
    };
  }
}
class RatingSummary {
  final int positiveClients;
  final double averageStars;
  final double communityScore;

  RatingSummary({required this.positiveClients,required this.averageStars,required this.communityScore});
  Map<String, dynamic> toJson() {
    return {
      'positiveClients': positiveClients,
      'averageStars': averageStars,
      'communityScore': communityScore,

    };
  }
}