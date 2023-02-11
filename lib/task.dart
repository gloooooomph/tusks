
abstract class Task {
  const Task({required this.name});
  final String name;
  double getUrgency(DateTime currentTime, DateTime lastCompleted);
  Map<String, dynamic> toJson();
  bool repeat();

  static Task fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('type') || json['type'] == 'daily') {
      return DailyTask.fromJson(json);
    } else if (json['type'] == 'oneOff') {
      return OneOffTask.fromJson(json);
    }
    throw Exception("inexhaustive pattern in task.fromJson");
  }
}

class DailyTask extends Task {
  const DailyTask({required super.name, required List<bool> this.days});

  static const int secondsInOneDay = 3600 * 24;

  final List<bool> days;

  @override
  double getUrgency(DateTime currentTime, DateTime lastCompleted) {
    if (currentTime.sameDayAs(lastCompleted) || !isActiveToday(currentTime)) {
      return 0.0;
    } else {
      return currentTime.difference(currentTime.atStartOfDay()).inSeconds / secondsInOneDay;
    }
  }

  bool isActiveToday(DateTime currentTime) {
    return days[currentTime.weekday];
  }

  DailyTask.fromJson(Map<String, dynamic> json) : days = json['days'].cast<bool>(), super(name: json['name']);

  @override
  Map<String, dynamic> toJson() {
    return {'name': name, 'days': days, 'type': 'daily'};
  }

  @override
  bool repeat() {
    return true;
  }
}

class OneOffTask extends Task {
  final DateTime deadline;
  final DateTime start;

  const OneOffTask({required super.name, required DateTime this.start, required DateTime this.deadline});

  @override
  double getUrgency(DateTime currentTime, DateTime lastCompleted) {
    return currentTime.fractionThroughTimePeriod(start, deadline);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'name': name, 'start': start.millisecondsSinceEpoch, 'deadline': deadline.millisecondsSinceEpoch, 'type': 'oneOff'};
  }

  OneOffTask.fromJson(Map<String, dynamic> json) : start = DateTime.fromMillisecondsSinceEpoch(json['start']), deadline = DateTime.fromMillisecondsSinceEpoch(json['deadline']), super(name: json['name']);

  @override
  bool repeat() {
    return false;
  }
}

class StartAndEnd {
  final DateTime start;
  final DateTime end;

  StartAndEnd(this.start, this.end);

  DateTime _adjustToToday(DateTime today, DateTime time) {
    return DateTime(today.year, today.month, time.day, time.hour, time.minute, time.second);
  }

  DateTime getStart(DateTime today) {
    return _adjustToToday(today, start);
  }

  DateTime getEnd(DateTime today) {
    return _adjustToToday(today, end);
  }
}

extension DateTimeUtils on DateTime {
  bool sameDayAs(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }

  DateTime atStartOfDay() {
    return DateTime(year, month, day, 0, 0, 0);
  }

  DateTime atEndOfDay() {
    return add(const Duration(days: 1)).atStartOfDay();
  }

  double fractionThroughTimePeriod(DateTime start, DateTime end) {
    return difference(start).inSeconds / end.difference(start).inSeconds;
  }
}