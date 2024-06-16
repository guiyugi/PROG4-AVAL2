import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/task_category.dart';

class ToDoProvider with ChangeNotifier {
  static const String _tasksUrl =
      'https://todo-list-21de2-default-rtdb.firebaseio.com/tasks';
  static const String _categoriesUrl =
      'https://todo-list-21de2-default-rtdb.firebaseio.com/categories.json';

  final List<Task> _tasks = [];
  final List<Category> _categories = [];

  List<Task> get tasks => _tasks;
  List<Category> get categories => _categories;

  Future<void> load() async {
    final tasksResponse = await http.get(Uri.parse('$_tasksUrl.json'));
    final categoriesResponse = await http.get(Uri.parse(_categoriesUrl));

    if (tasksResponse.statusCode == 200 &&
        categoriesResponse.statusCode == 200) {
      _tasks.clear();
      _parseTaskData(tasksResponse.body);

      _categories.clear();
      _parseCategoryData(categoriesResponse.body);

      notifyListeners();
    } else {}
  }

  void _parseTaskData(String responseBody) {
    final tasksData = jsonDecode(responseBody) as Map<String, dynamic>?;
    if (tasksData != null) {
      tasksData.forEach((key, value) {
        final task = Task(
          id: key,
          title: value['title'],
          description: value['description'],
          category: value['category'],
          dueDate: value['dueDate'] != null
              ? DateTime.parse(value['dueDate'])
              : null,
          dueTime: value['dueTime'] != null
              ? TimeOfDay(
                  hour: int.parse(value['dueTime'].split(':')[0]),
                  minute: int.parse(value['dueTime'].split(':')[1]),
                )
              : null,
        );
        _tasks.add(task);
      });
    }
  }

  void _parseCategoryData(String responseBody) {
    final categoriesData = jsonDecode(responseBody) as Map<String, dynamic>?;
    if (categoriesData != null) {
      categoriesData.forEach((key, value) {
        final category = Category(
          name: key,
          value: value,
        );
        _categories.add(category);
      });
    }
  }

  Future<void> addTask(String title, String description, String category,
      DateTime? dueDate, TimeOfDay? dueTime) async {
    final response = await http.post(
      Uri.parse('$_tasksUrl.json'),
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'dueDate': dueDate?.toIso8601String(),
        'dueTime': dueTime != null ? '${dueTime.hour}:${dueTime.minute}' : null,
      }),
    );

    if (response.statusCode == 200) {
      final newTask = Task(
        id: jsonDecode(response.body)['name'],
        title: title,
        description: description,
        category: category,
        dueDate: dueDate,
        dueTime: dueTime,
      );
      _tasks.add(newTask);
      notifyListeners();
    } else {
      throw Exception('Failed to add task');
    }
  }

  Future<void> updateTask(String id, String title, String description,
      String category, DateTime? dueDate, TimeOfDay? dueTime) async {
    final response = await http.patch(
      Uri.parse('$_tasksUrl/$id.json'),
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'dueDate': dueDate?.toIso8601String(),
        'dueTime': dueTime != null ? '${dueTime.hour}:${dueTime.minute}' : null,
      }),
    );

    if (response.statusCode == 200) {
      final updatedTask = Task(
        id: id,
        title: title,
        description: description,
        category: category,
        dueDate: dueDate,
        dueTime: dueTime,
      );
      final taskIndex = _tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
        notifyListeners();
      }
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final url = '$_tasksUrl/$taskId.json';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        _tasks.removeWhere((task) => task.id == taskId);
        notifyListeners();
      } else {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
