import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final List<TaskEntity> filteredTasks;
  final TaskStatus? statusFilter;
  final String? categoryFilter;

  const TaskLoaded({
    required this.tasks,
    required this.filteredTasks,
    this.statusFilter,
    this.categoryFilter,
  });

  @override
  List<Object?> get props => [tasks, filteredTasks, statusFilter, categoryFilter];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
