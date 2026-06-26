// lib/domain/repository/category_repository.dart

import '../model/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category>       getCategory(int id);
  Future<Category>       createCategory(Map<String, dynamic> payload);
  Future<Category>       updateCategory(int id, Map<String, dynamic> payload);
  Future<void>           deleteCategory(int id);
  Future<Map<String, dynamic>> getStats();
}