import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../provider/todo_provider.dart';

void showTaskDialog(
  BuildContext context, {
  required TextEditingController taskController,
  required TextEditingController descriptionController,
  String? selectedCategory,
  Task? task,
  Function()? onSave,
}) {
  bool isEditMode = task != null;
  taskController.text = task?.title ?? '';
  descriptionController.text = task?.description ?? '';
  selectedCategory = task?.category;

  DateTime? selectedDate = task?.dueDate;
  TimeOfDay? selectedTime = task?.dueTime;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditMode ? 'Editar tarefa' : 'Adicionar nova tarefa'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        hintText: 'Digite o título da tarefa',
                      ),
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Digite a descrição da tarefa',
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Consumer<ToDoProvider>(
                    builder: (context, provider, child) {
                      return DropdownButton<String>(
                        hint: const Text('Selecione uma categoria'),
                        value: selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        items: provider.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text(selectedDate != null
                              ? 'Data: ${selectedDate?.toLocal().toString().split(' ')[0]}'
                              : 'Selecione a data de vencimento'),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          child: Text(selectedTime != null
                              ? 'Horário: ${selectedTime?.format(context)}'
                              : 'Selecione o horário de vencimento'),
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (taskController.text.isNotEmpty &&
                      selectedCategory != null &&
                      selectedDate != null &&
                      selectedTime != null) {
                    final provider =
                        Provider.of<ToDoProvider>(context, listen: false);
                    if (isEditMode) {
                      await provider.updateTask(
                        task.id,
                        taskController.text,
                        descriptionController.text,
                        selectedCategory!,
                        selectedDate,
                        selectedTime,
                      );
                    } else {
                      await provider.addTask(
                        taskController.text,
                        descriptionController.text,
                        selectedCategory!,
                        selectedDate,
                        selectedTime,
                      );
                    }
                    if (onSave != null) {
                      onSave();
                    }
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Please fill in all fields.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text(isEditMode ? 'Salvar' : 'Adicionar'),
              ),
            ],
          );
        },
      );
    },
  );
}
