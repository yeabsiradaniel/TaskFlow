import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource _localDatasource;

  CategoryRepositoryImpl(this._localDatasource);

  @override
  Future<List<CategoryEntity>> getAllCategories() {
    return _localDatasource.getAllCategories();
  }

  @override
  Future<void> createCategory(CategoryEntity category) {
    return _localDatasource.saveCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> updateCategory(CategoryEntity category) {
    return _localDatasource.saveCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String id) {
    return _localDatasource.deleteCategory(id);
  }
}
