import 'package:flutest/task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weekday_selector/weekday_selector.dart';

class NewTask extends StatefulWidget {
  const NewTask({super.key, required this.callback});

  final void Function(Task) callback;

  @override
  State<StatefulWidget> createState() {
    return NewTaskState(callback);
  }
}

enum TaskType {
  oneOff('One Off'),
  daily('Daily'),
  delay('Delay');

  final String name;

  const TaskType(this.name);
}

class NewTaskState extends State<NewTask> {
  NewTaskState(void Function(Task) this.callback);

  final void Function(Task) callback;
  final _formKey = GlobalKey<FormState>();

  String currentTitle = '';
  TaskType taskType = TaskType.daily;
  List<bool> days = List.filled(7, true);
  DateTime deadline = DateTime.now().atEndOfDay();
  int minDelay = 0;
  int maxDelay = 0;
  Unit unit = Unit.days;

  Widget getTitleField() {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'You need a title idiot';
        }
        return null;
      },
      onChanged: (value) => currentTitle = value,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Name',
      ),
    );
  }

  Widget getWeekdaySelector() {
    return WeekdaySelector(
        onChanged: (int day) {
          setState(() {
            final index = day % 7;
            days[index] = !days[index];
          });
        },
        values: days);
  }

  Widget getTypeSelector() {
    var items = TaskType.values
        .map((item) =>
            DropdownMenuItem<TaskType>(child: Text(item.name), value: item))
        .toList();
    return DropdownButton(
        items: items,
        value: taskType,
        onChanged: (value) {
          setState(() {
            taskType = value!;
          });
        });
  }

  Widget getDeadlineSelector() {
    var button = OutlinedButton(
      onPressed: () async {
        DateTime? selected = await showDatePicker(
            context: context,
            initialDate: deadline,
            firstDate: DateTime.now(),
            lastDate: DateTime(3000));
        if (selected == null) {
          return;
        }
        setState(() {
          deadline = selected;
        });
      },
      child: Text(deadline.toString()),
    );
    return button;
  }

  Widget getIntField(String text, void Function(int) callback) {
    return TextFormField(
      onChanged: (text) {
        var asInt = int.tryParse(text) ?? 0;
        setState(() {
          callback(asInt);
        });
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: text,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'You need a number idiot';
        }
        return null;
      },
    );
  }

  Widget getMinDelaySelector() {
    return getIntField('Minimum time since last completion', (value) { 
      minDelay = value;
    });
  }

  Widget getMaxDelaySelector() {
    return getIntField('Maximum time since last completion', (value) {
      maxDelay = value;
    });
  }

  Widget getUnitSelector() {
    var items = Unit.values
        .map((item) =>
        DropdownMenuItem<Unit>(child: Text(item.name), value: item))
        .toList();
    return DropdownButton(
        items: items,
        value: unit,
        onChanged: (value) {
          setState(() {
            unit = value!;
          });
        });
  }

  // This'll need replacing at some point
  List<Widget> getWidgets() {
    if (taskType == TaskType.daily) {
      return [getTitleField(), getTypeSelector(), getWeekdaySelector()];
    } else if (taskType == TaskType.delay) {
      return [getTitleField(), getMinDelaySelector(), getMaxDelaySelector(), getUnitSelector()];
  } else {
      return [getTitleField(), getTypeSelector(), getDeadlineSelector()];
    }
  }

  Task buildTask() {
    if (taskType == TaskType.daily) {
      return DailyTask(name: currentTitle, days: days);
    } else if (taskType == TaskType.oneOff) {
      return OneOffTask(
          name: currentTitle, start: DateTime.now(), deadline: deadline);
    } else if (taskType == TaskType.delay) {
      return DelayTask(name: currentTitle, min: minDelay, max: maxDelay, unit: unit);
    } else {
        throw Exception("non exhaustive switch in buildTask");
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New task')),
      body: Form(
        key: _formKey,
        child: Column(
          children: getWidgets(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            callback(buildTask());
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
