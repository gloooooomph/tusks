import 'package:flutest/task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('New task')
      ),
      body: Form(
        key: _formKey,
        child: title,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            callback(DailyTask(name: currentTitle));
            Navigator.pop(context);
          }
        },
      ),
    );
  }

}