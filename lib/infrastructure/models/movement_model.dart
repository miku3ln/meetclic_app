import 'package:meetclic_app/domain/entities/movement.dart';

class MovementModel extends Movement {
  MovementModel.fromJson(Map<String, dynamic> json)
    : super(
        id: json['id'],
        dateRegister: DateTime.parse(json['date_register']),
        description: json['description'],
        inputMovementName: json['input_movement_name'],
        inputMovementValue: json['input_movement_value'],
        tipoTransactionValue: json['tipo_transaction_value'],
        tipoTransactionName: json['tipo_transaction_name'],
        amount: json['amount'],
        typeMoneyValue: json['type_money_value'],
        typeMoneyName: json['type_money_name'],
        processName: json['process_name'],
        sourceProcess: json['source_process'],
        activityName: json['activity_name'],
      );
}
