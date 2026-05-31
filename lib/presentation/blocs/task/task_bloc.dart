import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc(this._taskRepository) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ReorderTasks>(_onReorderTasks);
    on<FilterTasksByStatus>(_onFilterByStatus);
    on<FilterTasksByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getAllTasks();
      emit(TaskLoaded(tasks: tasks, filteredTasks: tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.createTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('Failed to add task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.updateTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.taskId);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('Failed to delete task: ${e.toString()}'));
    }
  }

  Future<void> _onReorderTasks(ReorderTasks event, Emitter<TaskState> emit) async {
    if (state is! TaskLoaded) return;
    final currentState = state as TaskLoaded;

    final tasks = List<TaskEntity>.from(currentState.filteredTasks);
    final item = tasks.removeAt(event.oldIndex);
    final newIndex = event.newIndex > event.oldIndex
        ? event.newIndex - 1
        : event.newIndex;
    tasks.insert(newIndex, item);

    final reordered = tasks
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(order: entry.key))
        .toList();

    try {
      await _taskRepository.reorderTasks(reordered);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('Failed to reorder tasks: ${e.toString()}'));
    }
  }

  void _onFilterByStatus(FilterTasksByStatus event, Emitter<TaskState> emit) {
    if (state is! TaskLoaded) return;
    final currentState = state as TaskLoaded;
    final filtered = _applyFilters(
      currentState.tasks,
      statusFilter: event.status,
      categoryFilter: currentState.categoryFilter,
    );
    emit(TaskLoaded(
      tasks: currentState.tasks,
      filteredTasks: filtered,
      statusFilter: event.status,
      categoryFilter: currentState.categoryFilter,
    ));
  }

  void _onFilterByCategory(FilterTasksByCategory event, Emitter<TaskState> emit) {
    if (state is! TaskLoaded) return;
    final currentState = state as TaskLoaded;
    final filtered = _applyFilters(
      currentState.tasks,
      statusFilter: currentState.statusFilter,
      categoryFilter: event.categoryId,
    );
    emit(TaskLoaded(
      tasks: currentState.tasks,
      filteredTasks: filtered,
      statusFilter: currentState.statusFilter,
      categoryFilter: event.categoryId,
    ));
  }

  List<TaskEntity> _applyFilters(
    List<TaskEntity> tasks, {
    TaskStatus? statusFilter,
    String? categoryFilter,
  }) {
    var filtered = tasks;
    if (statusFilter != null) {
      filtered = filtered.where((t) => t.status == statusFilter).toList();
    }
    if (categoryFilter != null) {
      filtered = filtered.where((t) => t.categoryId == categoryFilter).toList();
    }
    return filtered;
  }
}
