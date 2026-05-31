import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskEntity task;
  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;
  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ReorderTasks extends TaskEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderTasks(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class FilterTasksByStatus extends TaskEvent {
  final TaskStatus? status;
  const FilterTasksByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class FilterTasksByCategory extends TaskEvent {
  final String? categoryId;
  const FilterTasksByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
