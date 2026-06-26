// lib/data/remote/api/product_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/product.dart';

abstract class ProductRemoteDatasource {
  Future<PaginatedProducts> getProducts({
    String?  search,
    int?     category,
    double?  priceMin,
    double?  priceMax,
    int?     stockMin,
    bool?    isActive,
    String?  ordering,
    int      page,
    int      pageSize,
  });
  Future<Product>             getProduct(int id);
  Future<Product>             createProduct(Map<String, dynamic> payload);
  Future<Product>             updateProduct(int id, Map<String, dynamic> payload);
  Future<void>                deleteProduct(int id);
  Future<Map<String, dynamic>> restock(int id, int quantity);
  Future<Map<String, dynamic>> getStats();
}

class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  final Dio _dio;
  ProductRemoteDatasourceImpl(this._dio);

  @override
  Future<PaginatedProducts> getProducts({
    String?  search,
    int?     category,
    double?  priceMin,
    double?  priceMax,
    int?     stockMin,
    bool?    isActive,
    String?  ordering,
    int      page     = 1,
    int      pageSize = 12,
  }) async {
    try {
      final params = <String, dynamic>{
        'page':      page,
        'page_size': pageSize,
        if (search   != null) 'search':    search,
        if (category != null) 'category':  category,
        if (priceMin != null) 'price_min': priceMin,
        if (priceMax != null) 'price_max': priceMax,
        if (stockMin != null) 'stock_min': stockMin,
        if (isActive != null) 'is_active': isActive,
        if (ordering != null) 'ordering':  ordering,
      };
      final res = await _dio.get('/products/', queryParameters: params);
      return PaginatedProducts.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      final res = await _dio.get('/products/$id/');
      return Product.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Product> createProduct(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/products/', data: payload);
      return Product.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Product> updateProduct(int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.patch('/products/$id/', data: payload);
      return Product.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/products/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> restock(int id, int quantity) async {
    try {
      final res = await _dio.post('/products/$id/restock/', data: {'quantity': quantity});
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _dio.get('/products/stats/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final productDatasourceProvider = Provider<ProductRemoteDatasource>((ref) {
  return ProductRemoteDatasourceImpl(ref.watch(dioProvider));
});