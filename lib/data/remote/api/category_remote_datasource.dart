// lib/data/remote/api/category_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/category.dart';

abstract class CategoryRemoteDatasource {
  Future<List<Category>> getCategories();
  Future<Category>       getCategory(int id);
  Future<Category>       createCategory(Map<String, dynamic> payload);
  Future<Category>       updateCategory(int id, Map<String, dynamic> payload);
  Future<void>           deleteCategory(int id);
  Future<Map<String, dynamic>> getStats();
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final Dio _dio;
  CategoryRemoteDatasourceImpl(this._dio);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final res = await _dio.get('/categories/');
      final data = res.data as Map<String, dynamic>;
      return (data['results'] as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Category> getCategory(int id) async {
    try {
      final res = await _dio.get('/categories/$id/');
      return Category.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/categories/', data: payload);
      return Category.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.patch('/categories/$id/', data: payload);
      return Category.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('/categories/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _dio.get('/categories/stats/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final categoryDatasourceProvider = Provider<CategoryRemoteDatasource>((ref) {
  return CategoryRemoteDatasourceImpl(ref.watch(dioProvider));
});