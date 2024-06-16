import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.dueDate,
    this.dueTime,
  });
}
