import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryCubit(this._categoryRepository) : super(CategoryInitial());

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await _categoryRepository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories'));
    }
  }

  Future<void> addCategory(CategoryEntity category) async {
    try {
      await _categoryRepository.createCategory(category);
      await loadCategories();
    } catch (e) {
      emit(CategoryError('Failed to add category'));
    }
  }

  Future<void> updateCategory(CategoryEntity category) async {
    try {
      await _categoryRepository.updateCategory(category);
      await loadCategories();
    } catch (e) {
      emit(CategoryError('Failed to update category'));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryRepository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      emit(CategoryError('Failed to delete category'));
    }
  }
}
