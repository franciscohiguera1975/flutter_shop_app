// lib/data/repository/category_repository_impl.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/category.dart';
import '../../domain/repository/category_repository.dart';
import '../remote/api/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource _datasource;
  CategoryRepositoryImpl(this._datasource);

  @override
  Future<List<Category>> getCategories() => _datasource.getCategories();

  @override
  Future<Category> getCategory(int id) => _datasource.getCategory(id);

  @override
  Future<Category> createCategory(Map<String, dynamic> payload) =>
      _datasource.createCategory(payload);

  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> payload) =>
      _datasource.updateCategory(id, payload);

  @override
  Future<void> deleteCategory(int id) => _datasource.deleteCategory(id);

  @override
  Future<Map<String, dynamic>> getStats() => _datasource.getStats();
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryDatasourceProvider));
});