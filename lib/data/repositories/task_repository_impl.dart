import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';
import '../datasources/remote/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource _localDatasource;
  final TaskRemoteDatasource _remoteDatasource;
  final FirebaseAuth _auth;

  TaskRepositoryImpl(this._localDatasource, this._remoteDatasource, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    // Try remote first, fall back to local cache
    if (_userId != null) {
      try {
        final remoteTasks = await _remoteDatasource.getAllTasks(_userId!);
        // Update local cache with remote data
        await _localDatasource.clearAll();
        await _localDatasource.saveTasks(remoteTasks);
        return remoteTasks;
      } catch (_) {
        // Offline: return cached data
      }
    }
    return _localDatasource.getAllTasks();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) {
    return _localDatasource.getTaskById(id);
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDatasource.saveTask(model);
    if (_userId != null) {
      try {
        await _remoteDatasource.saveTask(_userId!, model);
      } catch (_) {
        // Will sync next time getAllTasks is called
      }
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDatasource.saveTask(model);
    if (_userId != null) {
      try {
        await _remoteDatasource.saveTask(_userId!, model);
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDatasource.deleteTask(id);
    if (_userId != null) {
      try {
        await _remoteDatasource.deleteTask(_userId!, id);
      } catch (_) {}
    }
  }

  @override
  Future<void> reorderTasks(List<TaskEntity> tasks) async {
    final models = tasks.map((t) => TaskModel.fromEntity(t)).toList();
    await _localDatasource.saveTasks(models);
    if (_userId != null) {
      try {
        await _remoteDatasource.saveTasks(_userId!, models);
      } catch (_) {}
    }
  }
}
