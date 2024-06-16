import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../provider/todo_provider.dart';
import '../utils/task_dialogs.dart';
import '../widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  Timer? _expiryCheckTimer;
  final Set<String> _notifiedTasks = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _startExpiryCheckTimer();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _expiryCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final provider = Provider.of<ToDoProvider>(context, listen: false);
      await provider.load();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      final provider = Provider.of<ToDoProvider>(context, listen: false);
      await provider.load();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _startExpiryCheckTimer() {
    _expiryCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final provider = Provider.of<ToDoProvider>(context, listen: false);
      for (var task in provider.tasks) {
        if (_isTaskCloseToExpiry(task) && !_notifiedTasks.contains(task.id)) {
          _notifiedTasks.add(task.id);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _showApproachingExpiryNotification(task);
          });
        }
      }
      setState(() {});
    });
  }

  bool _isTaskCloseToExpiry(Task task) {
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

  void _showApproachingExpiryNotification(Task task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A tarefa "${task.title}" está se aproximando do vencimento!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'FECHAR',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showTaskDialog(
      context,
      taskController: _taskController,
      descriptionController: _descriptionController,
      selectedCategory: _selectedCategory,
      onSave: () {
        _refreshData();
      },
    );
  }

  void _showEditTaskDialog(Task task) {
    final previousCategory = _selectedCategory;
    _taskController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _selectedCategory = task.category;

    showTaskDialog(
      context,
      taskController: _taskController,
      descriptionController: _descriptionController,
      selectedCategory: _selectedCategory,
      task: task,
      onSave: () {
        _refreshData();
        _selectedCategory = previousCategory;
      },
    );
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ToDoProvider>(context);
    List<Task> tasks = provider.tasks;

    if (_selectedCategory != null && _selectedCategory != 'Todas') {
      tasks =
          tasks.where((task) => task.category == _selectedCategory).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TO DO List'),
        centerTitle: true,
        actions: [
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _filterByCategory,
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Todas',
                  child: Text('Todas as categorias'),
                ),
                ...provider.categories.map((category) {
                  return PopupMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Dismissible(
                    key: Key(task.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      try {
                        await provider.deleteTask(task.id);
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete task: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: TaskTile(
                      task: task,
                      onEdit: () => _showEditTaskDialog(task),
                      onApproachingExpiry: () =>
                          _showApproachingExpiryNotification(task),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
