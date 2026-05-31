import 'package:hive/hive.dart';
import '../../models/task_model.dart';

class TaskLocalDatasource {
  static const String _boxName = 'tasks';

  Future<Box<Map>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Map>(_boxName);
    }
    return Hive.box<Map>(_boxName);
  }

  Future<List<TaskModel>> getAllTasks() async {
    final box = await _openBox();
    return box.values
        .map((json) => TaskModel.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<TaskModel?> getTaskById(String id) async {
    final box = await _openBox();
    final json = box.get(id);
    if (json == null) return null;
    return TaskModel.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> saveTask(TaskModel task) async {
    final box = await _openBox();
    await box.put(task.id, task.toJson());
  }

  Future<void> deleteTask(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final box = await _openBox();
    final map = {for (var task in tasks) task.id: task.toJson()};
    await box.putAll(map);
  }

  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
