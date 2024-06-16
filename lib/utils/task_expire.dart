import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../provider/todo_provider.dart';

Timer startExpiryCheckTimer(BuildContext context) {
  return Timer.periodic(const Duration(minutes: 5), (timer) {
    final provider = Provider.of<ToDoProvider>(context, listen: false);
    final tasks = provider.tasks;

    for (var task in tasks) {
      if (isTaskApproachingExpiry(task)) {
        showExpirySnackbar(context, task);
      }
    }
  });
}

bool isTaskApproachingExpiry(Task task) {
  final now = DateTime.now();
  final dueDate = task.dueDate;
  final dueTime = task.dueTime;

  if (dueDate != null && dueTime != null) {
    final expiryDateTime = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );
    final difference = expiryDateTime.difference(now);
    return difference.inMinutes <= 30 && !difference.isNegative;
  }
  return false;
}

void showExpirySnackbar(BuildContext context, Task task) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('A tarefa "${task.title}" está próxima do vencimento'),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'Fechar',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

bool isTaskExpired(Task task) {
  if (task.dueDate == null || task.dueTime == null) {
    return false;
  }

  DateTime dueDateTime = DateTime(
    task.dueDate!.year,
    task.dueDate!.month,
    task.dueDate!.day,
    task.dueTime!.hour,
    task.dueTime!.minute,
  );

  return dueDateTime.isBefore(DateTime.now());
}

bool isTaskCloseToExpiry(Task task) {
  if (task.dueDate == null || task.dueTime == null) {
    return false;
  }

  DateTime twoHoursFromNow = DateTime.now().add(const Duration(hours: 2));

  DateTime dueDateTime = DateTime(
    task.dueDate!.year,
    task.dueDate!.month,
    task.dueDate!.day,
    task.dueTime!.hour,
    task.dueTime!.minute,
  );

  return dueDateTime.isAfter(DateTime.now()) &&
      dueDateTime.isBefore(twoHoursFromNow);
}

int calculateDaysExpired(Task task) {
  if (task.dueDate == null || task.dueTime == null) {
    return 0;
  }

  DateTime dueDateTime = DateTime(
    task.dueDate!.year,
    task.dueDate!.month,
    task.dueDate!.day,
    task.dueTime!.hour,
    task.dueTime!.minute,
  );

  return DateTime.now().difference(dueDateTime).inDays;
}
