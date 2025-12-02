import 'dart:convert';

class BusinessDay {
  final int id;
  final String name;
  final String text;
  final int type;
  final bool modelDay;
  final int businessId;
  final String status;
  final int weightDay;
  final ConfigTypeSchedule configTypeSchedule;

  BusinessDay({
    required this.id,
    required this.name,
    required this.text,
    required this.type,
    required this.modelDay,
    required this.businessId,
    required this.status,
    required this.weightDay,
    required this.configTypeSchedule,
  });

  factory BusinessDay.fromJson(Map<String, dynamic> json) {
    return BusinessDay(
      id: json['id'],
      name: json['name'],
      text: json['text'],
      type: json['type'],
      modelDay: json['modelDay'],
      businessId: json['business_id'],
      status: json['status'],
      weightDay: json['weight_day'],
      configTypeSchedule: ConfigTypeSchedule.fromJson(json['configTypeSchedule']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'text': text,
    'type': type,
    'modelDay': modelDay,
    'business_id': businessId,
    'status': status,
    'weight_day': weightDay,
    'configTypeSchedule': configTypeSchedule.toJson(),
  };

  static List<BusinessDay> listFromJson(String jsonString) {
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((e) => BusinessDay.fromJson(e)).toList();
  }
}

class ConfigTypeSchedule {
  final bool type;
  final List<ScheduleRange> data;

  ConfigTypeSchedule({
    required this.type,
    required this.data,
  });

  factory ConfigTypeSchedule.fromJson(Map<String, dynamic> json) {
    return ConfigTypeSchedule(
      type: json['type'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ScheduleRange.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class ScheduleRange {
  final ScheduleTime startTime;
  final ScheduleTime endTime;

  ScheduleRange({
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleRange.fromJson(Map<String, dynamic> json) {
    return ScheduleRange(
      startTime: ScheduleTime.fromJson(json['start_time']),
      endTime: ScheduleTime.fromJson(json['end_time']),
    );
  }

  Map<String, dynamic> toJson() => {
    'start_time': startTime.toJson(),
    'end_time': endTime.toJson(),
  };
}

class ScheduleTime {
  final int id;
  final String modelBreakdown;
  final bool error;
  final String msj;
  final bool init;

  ScheduleTime({
    required this.id,
    required this.modelBreakdown,
    required this.error,
    required this.msj,
    required this.init,
  });

  factory ScheduleTime.fromJson(Map<String, dynamic> json) {
    return ScheduleTime(
      id: json['id'],
      modelBreakdown: json['modelBreakdown'],
      error: json['error'],
      msj: json['msj'],
      init: json['init'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'modelBreakdown': modelBreakdown,
    'error': error,
    'msj': msj,
    'init': init,
  };
}
