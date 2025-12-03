import 'business_day.dart';

class DaySchedule {
  final String day;
  final bool isToday;
  final bool isOpen;
  final String timeRange;
  final bool isAllDay;
  final List<ScheduleRange> openRanges;
  DaySchedule({
    required this.day,
    required this.isToday,
    required this.isOpen,
    required this.timeRange,
    required this.isAllDay,
    required this.openRanges,
  });
}
