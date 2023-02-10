
abstract class Task {
  const Task({required this.name});
  final String name;
  double getUrgency(DateTime currentTime, DateTime lastCompleted);
  Map<String, dynamic> toJson();
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
    return {'name': name, 'days': days};
  }
}

class FrequentTask extends Task {
  const FrequentTask({required super.name,  required this.frequency});

  final Duration frequency;

  @override
  double getUrgency(DateTime currentTime, DateTime lastCompleted) {
    return (currentTime.difference(lastCompleted).inSeconds.toDouble() / frequency.inSeconds).clamp(0.0, 1.0);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
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
}