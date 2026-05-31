import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_titleController.text.trim().isEmpty) return;

    final task = TaskEntity(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _priority,
      createdAt: DateTime.now(),
      dueDate: _dueDate,
    );

    context.read<TaskBloc>().add(AddTask(task));
    Navigator.pop(context);
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Task',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Task title',
              prefixIcon: Icon(Icons.task_outlined),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<TaskPriority>(
                  segments: const [
                    ButtonSegment(
                      value: TaskPriority.low,
                      label: Text('Low'),
                      icon: Icon(Icons.arrow_downward, size: 16),
                    ),
                    ButtonSegment(
                      value: TaskPriority.medium,
                      label: Text('Med'),
                      icon: Icon(Icons.remove, size: 16),
                    ),
                    ButtonSegment(
                      value: TaskPriority.high,
                      label: Text('High'),
                      icon: Icon(Icons.arrow_upward, size: 16),
                    ),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (selected) {
                    setState(() => _priority = selected.first);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _selectDueDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              _dueDate != null
                  ? 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                  : 'Set due date',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _onSave,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Create Task'),
            ),
          ),
        ],
      ),
    );
  }
}
