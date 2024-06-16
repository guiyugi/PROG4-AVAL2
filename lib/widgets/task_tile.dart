import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final Function onEdit;
  final Function? onApproachingExpiry;

  const TaskTile({
    super.key,
    required this.task,
    required this.onEdit,
    this.onApproachingExpiry,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _isCloseToExpiry = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkExpiryCondition());
  }

  void _checkExpiryCondition() {
    if (_isTaskCloseToExpiry(widget.task) &&
        widget.onApproachingExpiry != null) {
      widget.onApproachingExpiry!();
      setState(() {
        _isCloseToExpiry = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTaskExpired = _isTaskExpired(widget.task);
    int daysExpired = calculateDaysExpired(widget.task);

    Color cardColor = isTaskExpired
        ? Colors.grey[300]!
        : (_isCloseToExpiry ? Colors.red[100]! : Colors.white);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: _isCloseToExpiry ? Colors.red : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Título: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  decoration: isTaskExpired ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                widget.task.title.isNotEmpty
                    ? widget.task.title
                    : 'Título não fornecido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: isTaskExpired ? TextDecoration.lineThrough : null,
                  color: isTaskExpired
                      ? Colors.grey
                      : (_isCloseToExpiry ? Colors.red : Colors.black),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Descrição: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  decoration: isTaskExpired ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                widget.task.description != null &&
                        widget.task.description!.isNotEmpty
                    ? widget.task.description!
                    : 'Descrição não fornecida',
                style: TextStyle(
                  fontSize: 16,
                  decoration: isTaskExpired ? TextDecoration.lineThrough : null,
                  color: isTaskExpired
                      ? Colors.grey
                      : (_isCloseToExpiry ? Colors.red : Colors.black),
                ),
              ),
              const SizedBox(height: 4.0),
              // Categoria
              Text(
                'Categoria: ${widget.task.category}',
                style: TextStyle(
                  fontSize: 16,
                  decoration: isTaskExpired ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4.0),
              if (widget.task.dueDate != null || widget.task.dueTime != null)
                Row(
                  children: [
                    if (widget.task.dueDate != null)
                      Text(
                        'Data: ${widget.task.dueDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 16,
                          decoration:
                              isTaskExpired ? TextDecoration.lineThrough : null,
                          color: isTaskExpired
                              ? Colors.grey
                              : (_isCloseToExpiry ? Colors.red : Colors.black),
                        ),
                      ),
                    if (widget.task.dueDate != null &&
                        widget.task.dueTime != null)
                      const SizedBox(width: 8),
                    if (widget.task.dueTime != null)
                      Text(
                        'Hora: ${widget.task.dueTime!.format(context)}',
                        style: TextStyle(
                          fontSize: 16,
                          decoration:
                              isTaskExpired ? TextDecoration.lineThrough : null,
                          color: isTaskExpired
                              ? Colors.grey
                              : (_isCloseToExpiry ? Colors.red : Colors.black),
                        ),
                      ),
                  ],
                ),

              if (_isCloseToExpiry)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Aproximando-se do vencimento',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isTaskExpired)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '(EXPIRADO HÁ $daysExpired DIAS)',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => widget.onEdit(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTaskExpired(Task task) {
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
}
