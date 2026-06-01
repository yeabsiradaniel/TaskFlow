import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/category_local_datasource.dart';
import '../datasources/remote/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource _localDatasource;
  final CategoryRemoteDatasource _remoteDatasource;
  final FirebaseAuth _auth;

  CategoryRepositoryImpl(
      this._localDatasource, this._remoteDatasource, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    if (_userId != null) {
      try {
        final remoteCategories =
            await _remoteDatasource.getAllCategories(_userId!);
        for (final cat in remoteCategories) {
          await _localDatasource.saveCategory(cat);
        }
        return remoteCategories;
      } catch (_) {}
    }
    return _localDatasource.getAllCategories();
  }

  @override
  Future<void> createCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDatasource.saveCategory(model);
    if (_userId != null) {
      try {
        await _remoteDatasource.saveCategory(_userId!, model);
      } catch (_) {}
    }
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDatasource.saveCategory(model);
    if (_userId != null) {
      try {
        await _remoteDatasource.saveCategory(_userId!, model);
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDatasource.deleteCategory(id);
    if (_userId != null) {
      try {
        await _remoteDatasource.deleteCategory(_userId!, id);
      } catch (_) {}
    }
  }
}
