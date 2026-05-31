import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('dismiss_${task.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: IconButton(
            icon: Icon(
              isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isCompleted
                  ? Colors.green
                  : _priorityColor(task.priority),
            ),
            onPressed: onToggleStatus,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted
                  ? Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)
                  : null,
            ),
          ),
          subtitle: task.dueDate != null
              ? Text(
                  'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isDueSoon(task.dueDate!)
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: _priorityColor(task.priority),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  bool _isDueSoon(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now().add(const Duration(days: 1)));
  }
}
