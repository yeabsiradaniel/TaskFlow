import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource _localDatasource;

  TaskRepositoryImpl(this._localDatasource);

  @override
  Future<List<TaskEntity>> getAllTasks() {
    return _localDatasource.getAllTasks();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) {
    return _localDatasource.getTaskById(id);
  }

  @override
  Future<void> createTask(TaskEntity task) {
    return _localDatasource.saveTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> updateTask(TaskEntity task) {
    return _localDatasource.saveTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String id) {
    return _localDatasource.deleteTask(id);
  }

  @override
  Future<void> reorderTasks(List<TaskEntity> tasks) {
    final models = tasks.map((t) => TaskModel.fromEntity(t)).toList();
    return _localDatasource.saveTasks(models);
  }
}
