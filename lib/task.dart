
abstract class Task {
  const Task({required this.name});
  final String name;
  double getUrgency(DateTime currentTime, DateTime lastCompleted);

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class DailyTask extends Task {
  const DailyTask({required super.name});

  static const int secondsInOneDay = 3600 * 24;

  @override
  double getUrgency(DateTime currentTime, DateTime lastCompleted) {
    if (currentTime.sameDayAs(lastCompleted)) {
      return 0.0;
    } else {
      return currentTime.difference(currentTime.atStartOfDay()).inSeconds / secondsInOneDay;
    }
  }

  DailyTask.fromJson(Map<String, dynamic> json) : super(name: json['name']);
  
}

class FrequentTask extends Task {
  const FrequentTask({required super.name,  required this.frequency});

  final Duration frequency;

  @override
  double getUrgency(DateTime currentTime, DateTime lastCompleted) {
    return (currentTime.difference(lastCompleted).inSeconds.toDouble() / frequency.inSeconds).clamp(0.0, 1.0);
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