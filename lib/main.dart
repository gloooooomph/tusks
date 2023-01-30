import 'dart:async';
import 'dart:html';

import 'package:flutest/task.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  var task = DailyTask(name: "chekese");
  // var tasks = List<TaskData>.generate(200, (index) => TaskData(UrgentTask(index.toString(), index.toDouble() / 200), DateTime.now()));
  var time = DateTime.now();
  var widget = TasksApp();
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text("title")
      ),
      body: Center(
        child: widget,
      )
    ),
    title: 'lkjhlkjh'
  ));
}

Color getColor(double urgency) {
  var red = Colors.green.red + urgency * (Colors.red.red - Colors.green.red);
  var green = Colors.green.green + urgency * (Colors.red.green - Colors.green.green);
  var blue = Colors.green.blue + urgency * (Colors.red.blue - Colors.green.blue);
  return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1.0);
}

class Bar extends StatelessWidget {
  const Bar({super.key, required this.task, required this.currentTime, required this.lastCompleted, required this.completeTask});

  final Task task;
  final DateTime currentTime;
  final DateTime lastCompleted;
  final void Function(Task) completeTask;

  @override
  Widget build(BuildContext context) {
    var urgency = task.getUrgency(currentTime, lastCompleted);
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: getColor(urgency),
        ),
        padding: EdgeInsets.all(5.0),
        child: Text(task.name),
        margin: EdgeInsets.all(5.0),
      ),
      onDoubleTap: () => completeTask(task),
    );
  }
}

class Bars extends StatelessWidget {
  const Bars({super.key, required this.tasks, required this.currentTime, required this.completeTask});

  final List<TaskData> tasks;
  final DateTime currentTime;
  final void Function(Task) completeTask;

  @override
  Widget build(BuildContext context) {
    tasks.sort((b, a) => (a.task.getUrgency(currentTime, a.lastCompleted) - b.task.getUrgency(currentTime, b.lastCompleted)).sign.toInt());
    return ListView(
      children: tasks.map((e) => Bar(
        task: e.task,
        currentTime: currentTime,
        lastCompleted: e.lastCompleted,
        completeTask: completeTask,
      )).toList()
    );
  }
}

class TaskData {
  const TaskData(this.task, this.lastCompleted);

  final Task task;
  final DateTime lastCompleted;
}

class TasksApp extends StatefulWidget {
  const TasksApp({super.key});

  @override
  State<StatefulWidget> createState() {
    var tasks = Map.fromEntries(List<MapEntry<Task, DateTime>>.generate(10, (index) => MapEntry(FrequentTask(frequency: Duration(minutes: 1), name: index.toString()), DateTime.now().atStartOfDay())));
    return TasksAppState(tasks);
  }}

class TasksAppState extends State {
  TasksAppState(this.tasks)
  : now = DateTime.now();

  Map<Task, DateTime> tasks;
  DateTime now;

  @override
  Widget build(BuildContext context) {
    var currentTime = DateTime.now();
    var tasksAsList = tasks.entries.map((entry) => TaskData(entry.key, entry.value)).toList();
    completeTask(task) => setState(() =>tasks[task] = now);
    return Bars(tasks: tasksAsList, currentTime: currentTime, completeTask: completeTask,);
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) => setState(() {
      now = DateTime.now();
    }));
  }
}