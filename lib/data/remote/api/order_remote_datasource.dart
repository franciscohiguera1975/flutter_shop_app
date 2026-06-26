// lib/data/remote/api/order_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/order.dart';

abstract class OrderRemoteDatasource {
  Future<PaginatedOrders>      getOrders({int? page, String? status});
  Future<Order>                getOrder(int id);
  Future<Order>                createOrder();
  Future<Order>                addItem(int orderId, int productId, int quantity);
  Future<Order>                confirmOrder(int orderId);
  Future<Order>                updateStatus(int orderId, String status);
  Future<Map<String, dynamic>> getStats();
}

class OrderRemoteDatasourceImpl implements OrderRemoteDatasource {
  final Dio _dio;
  OrderRemoteDatasourceImpl(this._dio);

  @override
  Future<PaginatedOrders> getOrders({int? page, String? status}) async {
    try {
      final params = <String, dynamic>{
        if (page   != null) 'page':   page,
        if (status != null) 'status': status,
      };
      final res = await _dio.get('/orders/', queryParameters: params);
      return PaginatedOrders.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Order> getOrder(int id) async {
    try {
      final res = await _dio.get('/orders/$id/');
      return Order.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Order> createOrder() async {
    try {
      print('DEBUG: POST /orders/ - Creando orden');
      final res = await _dio.post('/orders/', data: {});
      print('DEBUG: POST /orders/ - Respuesta: ${res.statusCode}');
      print('DEBUG: POST /orders/ - Data: ${res.data}');
      return Order.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('DEBUG: POST /orders/ - Error: ${e.message}');
      print('DEBUG: POST /orders/ - Response: ${e.response?.data}');
      print('DEBUG: POST /orders/ - Type: ${e.type}');
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Order> addItem(int orderId, int productId, int quantity) async {
    try {
      print('DEBUG: POST /orders/$orderId/add-item/ - product_id: $productId, quantity: $quantity');
      final res = await _dio.post(
        '/orders/$orderId/add-item/',
        data: {'product_id': productId, 'quantity': quantity},
      );
      print('DEBUG: POST /orders/$orderId/add-item/ - Respuesta: ${res.statusCode}');
      return Order.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('DEBUG: POST /orders/$orderId/add-item/ - Error: ${e.message}');
      print('DEBUG: POST /orders/$orderId/add-item/ - Response: ${e.response?.data}');
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Order> confirmOrder(int orderId) async {
    try {
      print('DEBUG: POST /orders/$orderId/confirm/ - Confirmando orden');
      final res = await _dio.post('/orders/$orderId/confirm/');
      print('DEBUG: POST /orders/$orderId/confirm/ - Respuesta: ${res.statusCode}');
      print('DEBUG: POST /orders/$orderId/confirm/ - Data: ${res.data}');
      return Order.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('DEBUG: POST /orders/$orderId/confirm/ - Error: ${e.message}');
      print('DEBUG: POST /orders/$orderId/confirm/ - Response: ${e.response?.data}');
      print('DEBUG: POST /orders/$orderId/confirm/ - Type: ${e.type}');
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Order> updateStatus(int orderId, String status) async {
    try {
      final res = await _dio.post(
        '/orders/$orderId/update-status/',
        data: {'status': status},
      );
      return Order.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _dio.get('/orders/stats/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final orderDatasourceProvider = Provider<OrderRemoteDatasource>((ref) {
  return OrderRemoteDatasourceImpl(ref.watch(dioProvider));
});