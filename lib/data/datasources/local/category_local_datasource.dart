import 'package:hive/hive.dart';
import '../../models/category_model.dart';

class CategoryLocalDatasource {
  static const String _boxName = 'categories';

  Future<Box<Map>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Map>(_boxName);
    }
    return Hive.box<Map>(_boxName);
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final box = await _openBox();
    return box.values
        .map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> saveCategory(CategoryModel category) async {
    final box = await _openBox();
    await box.put(category.id, category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
