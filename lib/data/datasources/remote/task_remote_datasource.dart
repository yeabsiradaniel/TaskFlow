import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_model.dart';

class TaskRemoteDatasource {
  final FirebaseFirestore _firestore;

  TaskRemoteDatasource(this._firestore);

  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  Future<List<TaskModel>> getAllTasks(String userId) async {
    final snapshot =
        await _tasksRef(userId).orderBy('order').get();
    return snapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveTask(String userId, TaskModel task) async {
    await _tasksRef(userId).doc(task.id).set(task.toJson());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).delete();
  }

  Future<void> saveTasks(String userId, List<TaskModel> tasks) async {
    final batch = _firestore.batch();
    for (final task in tasks) {
      batch.set(_tasksRef(userId).doc(task.id), task.toJson());
    }
    await batch.commit();
  }
}
