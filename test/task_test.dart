import 'package:flutest/task.dart';
import 'package:test/test.dart';

void main() {

  var now = DateTime.now();
  var epoch = DateTime.fromMillisecondsSinceEpoch(0);

  var sundayStart = DateTime(1993, 6, 6, 0, 0, 0);
  var sundayEnd = sundayStart.atEndOfDay();
  var sundayNoon = sundayStart.copyWith(hour: 12);
  var justBeforeSunday = DateTime(1993, 6, 5, 23, 59, 59);
  var justAfterSunday = sundayEnd.copyWith(second: 1);

  // test('task with no days set is not urgent', () {
  //   var task = DailyTask(name: 'asdf', days: List.filled(7, false));
  //   expect(task.getUrgency(now, epoch), equals(0.0));
  // });

  test('task that should have been done yesterday is urgent', () {
    var task = DailyTask(name: 'asdf', days: List.filled(7, true));
    expect(task.getUrgency(justAfterSunday, justBeforeSunday), equals(1.0));
  });

  test('task that should have been done yesterday is urgent even if we\'re not doing it today', () {
    var task = DailyTask(name: 'asdf', days: List.generate(7, (index) {
      if (index == 5) {
        return true;
      } else {
        return false;
      }
    }));
    expect(task.getUrgency(justAfterSunday, justBeforeSunday), equals(1.0));
  });

  test('task that was done yesterday is not urgent if we\'re not doing it today', () {
    var task = DailyTask(name: 'asdf', days: List.generate(7, (index) {
      if (index == 5) {
        return true;
      } else {
        return false;
      }
    }));
    expect(task.getUrgency(justAfterSunday, sundayNoon), equals(0.0));
  });

  test('task being done today is semi urgent', () {
    var task = DailyTask(name: 'asdf', days: List.filled(7, true));
    expect(task.getUrgency(sundayNoon, justBeforeSunday), equals(0.5));
  });

  test('task being done today is not urgent if we\'ve done it', () {
    var task = DailyTask(name: 'asdf', days: List.filled(7, true));
    expect(task.getUrgency(sundayNoon, sundayNoon.subtract(Duration(hours: 1))), equals(0.0));
  });

}