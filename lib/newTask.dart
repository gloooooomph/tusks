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

class NewTaskState extends State<NewTask> {
  NewTaskState(void Function(Task) this.callback);
  final void Function(Task) callback;
  final _formKey = GlobalKey<FormState>();

  String currentTitle = '';
  List<bool> days = List.filled(7, true);

  @override
  Widget build(BuildContext context) {
    TextFormField title = TextFormField(
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
    WeekdaySelector daysSelector = WeekdaySelector(
        onChanged: (int day) {
          setState(() {
            final index = day % 7;
            days[index] = !days[index];
          });
        },
        values: days);
    return Scaffold(
      appBar: AppBar(
        title: Text('New task')
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            title, daysSelector
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            callback(DailyTask(name: currentTitle, days: days));
            Navigator.pop(context);
          }
        },
      ),
    );
  }

}