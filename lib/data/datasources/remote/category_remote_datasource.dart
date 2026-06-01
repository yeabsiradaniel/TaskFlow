import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';

class CategoryRemoteDatasource {
  final FirebaseFirestore _firestore;

  CategoryRemoteDatasource(this._firestore);

  CollectionReference<Map<String, dynamic>> _categoriesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('categories');
  }

  Future<List<CategoryModel>> getAllCategories(String userId) async {
    final snapshot = await _categoriesRef(userId).get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveCategory(String userId, CategoryModel category) async {
    await _categoriesRef(userId).doc(category.id).set(category.toJson());
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    await _categoriesRef(userId).doc(categoryId).delete();
  }
}
