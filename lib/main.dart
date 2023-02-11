import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutest/newTask.dart';
import 'package:flutest/task.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  var widget = FutureBuilder<String>(
      future: TasksApp.getInitialState(),
      builder: (BuildContext context, AsyncSnapshot<String> snap) {
        log('rebuilding ${snap.data}');
        var data = snap.data;
        if (data == null) {
          return Text('Loading');
        } else {
          return TasksApp(initialStateString: data);
        }
      }
  );
  runApp(MaterialApp(
    home: widget,
    title: 'lkjhlkjh',
  ));
}

Color getColor(double urgency) {
  var red = Colors.green.red + urgency * (Colors.red.red - Colors.green.red);
  var green =
      Colors.green.green + urgency * (Colors.red.green - Colors.green.green);
  var blue =
      Colors.green.blue + urgency * (Colors.red.blue - Colors.green.blue);
  return Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1.0);
}

class Bar extends StatelessWidget {
  const Bar(
      {super.key,
      required this.task,
      required this.currentTime,
      required this.lastCompleted,
      required this.completeTask});

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
  const Bars(
      {super.key,
      required this.tasks,
      required this.currentTime,
      required this.completeTask});

  final List<TaskData> tasks;
  final DateTime currentTime;
  final void Function(Task) completeTask;

  @override
  Widget build(BuildContext context) {
    tasks.sort((b, a) => (a.task.getUrgency(currentTime, a.lastCompleted) -
            b.task.getUrgency(currentTime, b.lastCompleted))
        .sign
        .toInt());
    return ListView(
        children: tasks
            .map((e) => Bar(
                  task: e.task,
                  currentTime: currentTime,
                  lastCompleted: e.lastCompleted,
                  completeTask: completeTask,
                ))
            .toList());
  }
}

class TaskData {
  const TaskData(this.task, this.lastCompleted);

  final Task task;
  final DateTime lastCompleted;
}

class TasksApp extends StatefulWidget {
  const TasksApp({super.key, required this.initialStateString});
  final String initialStateString;

  static Future<String> getInitialState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(TasksAppState.PREFS_KEY);
    if (data == null) {
      return '';
    } else {
      return data;
    };
  }

  @override
  State<StatefulWidget> createState() {
    log("localiss: $initialStateString");
    if (initialStateString == '') {
      return TasksAppState({});
    }
    var encoded = jsonDecode(initialStateString);
    log("state: $encoded");
    var tasks = encoded.map<Task, DateTime>((key, value) => MapEntry(Task.fromJson(jsonDecode(key)), DateTime.fromMillisecondsSinceEpoch(value)));
    log("tasks: $tasks");
    return TasksAppState(tasks);
  }
}

class TasksAppState extends State {
  TasksAppState(this.tasks) : now = DateTime.now();
  static const String PREFS_KEY = "tasks_state";

  Map<Task, DateTime> tasks;
  DateTime now;

  Future<void> serializeState() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, int> stringifiedTasks = tasks.map((key, value) => MapEntry(jsonEncode(key.toJson()), value.millisecondsSinceEpoch));
    String encoded = jsonEncode(stringifiedTasks);
    await prefs.setString(PREFS_KEY, encoded);
    final prefs2 = await SharedPreferences.getInstance();
    String? thing = prefs2.getString(PREFS_KEY);
    log("$thing");
  }

  @override
  Widget build(BuildContext context) {
    var currentTime = DateTime.now();
    var tasksAsList =
        tasks.entries.map((entry) => TaskData(entry.key, entry.value)).toList();
    completeTask(task) => setState(() {
      if (task.repeat()) {
        tasks[task] = now;
      } else {
        tasks.remove(task);
      }
      serializeState();
    });
    return Scaffold(
        appBar: AppBar(title: Text("title")),
        body: Center(
          child: Bars(
            tasks: tasksAsList,
            currentTime: currentTime,
            completeTask: completeTask,
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return NewTask(callback: (task) {
                  setState(() {
                    tasks[task] = DateTime.fromMicrosecondsSinceEpoch(0);
                    serializeState();
                  });
                });
              }));
            },
            child: const Icon(Icons.create)
        ));
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(
        Duration(seconds: 1),
        (timer) => setState(() {
              now = DateTime.now();
            }));
  }
}
