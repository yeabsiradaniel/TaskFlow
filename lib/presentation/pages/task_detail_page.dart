import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/task_entity.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is! TaskLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final task = state.tasks.where((t) => t.id == taskId).firstOrNull;
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Task not found')),
          );
        }

        final isCompleted = task.status == TaskStatus.completed;
        final priorityColor = _priorityColor(task.priority);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Details'),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: theme.colorScheme.error),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete Task'),
                      content: const Text(
                          'Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context
                                .read<TaskBloc>()
                                .add(DeleteTask(task.id));
                            context.pop();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [
                              Colors.green.withValues(alpha: 0.15),
                              Colors.green.withValues(alpha: 0.05),
                            ]
                          : [
                              priorityColor.withValues(alpha: 0.15),
                              priorityColor.withValues(alpha: 0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(
                        color: isCompleted ? Colors.green : priorityColor,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        color: isCompleted ? Colors.green : priorityColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          task.title,
                          style:
                              theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      theme,
                      icon: Icons.flag_rounded,
                      label: task.priority.name.toUpperCase(),
                      color: priorityColor,
                    ),
                    _buildInfoChip(
                      theme,
                      icon: Icons.circle,
                      label: task.status.name,
                      color: _statusColor(task.status),
                    ),
                    if (task.dueDate != null)
                      _buildInfoChip(
                        theme,
                        icon: Icons.calendar_today_rounded,
                        label:
                            '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                        color: _isDueSoon(task.dueDate!)
                            ? Colors.red
                            : theme.colorScheme.primary,
                      ),
                  ],
                ),

                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.description!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                Text(
                  'Created ${_formatFullDate(task.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.icon(
                onPressed: () {
                  final newStatus = isCompleted
                      ? TaskStatus.pending
                      : TaskStatus.completed;
                  context
                      .read<TaskBloc>()
                      .add(UpdateTask(task.copyWith(status: newStatus)));
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      isCompleted ? theme.colorScheme.secondary : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(isCompleted ? Icons.undo_rounded : Icons.check_rounded),
                label: Text(
                  isCompleted ? 'Mark as Pending' : 'Mark as Complete',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  bool _isDueSoon(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
