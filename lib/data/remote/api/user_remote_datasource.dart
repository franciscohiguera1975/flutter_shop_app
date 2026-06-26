// lib/data/remote/api/user_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/user.dart';

class PaginatedUsers {
  final int        count;
  final String?    next;
  final List<User> results;
  const PaginatedUsers({required this.count, required this.next, required this.results});

  factory PaginatedUsers.fromJson(Map<String, dynamic> j) => PaginatedUsers(
    count:   j['count']   as int,
    next:    j['next']    as String?,
    results: (j['results'] as List)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

abstract class UserRemoteDatasource {
  Future<PaginatedUsers>       getUsers({String? search, bool? isStaff, bool? isActive});
  Future<User>                 createUser(Map<String, dynamic> payload);
  Future<User>                 updateUser(int id, Map<String, dynamic> payload);
  Future<void>                 deleteUser(int id);
  Future<bool>                 toggleActive(int id);
  Future<Map<String, dynamic>> getStats();
}

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final Dio _dio;
  UserRemoteDatasourceImpl(this._dio);

  @override
  Future<PaginatedUsers> getUsers({String? search, bool? isStaff, bool? isActive}) async {
    try {
      final params = <String, dynamic>{
        if (search   != null) 'search':    search,
        if (isStaff  != null) 'is_staff':  isStaff,
        if (isActive != null) 'is_active': isActive,
      };
      final res = await _dio.get('/users/', queryParameters: params);
      return PaginatedUsers.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<User> createUser(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/users/', data: payload);
      return User.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<User> updateUser(int id, Map<String, dynamic> payload) async {
    try {
      final res = await _dio.patch('/users/$id/', data: payload);
      return User.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/users/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<bool> toggleActive(int id) async {
    try {
      final res = await _dio.post('/users/$id/toggle-active/');
      return res.data['is_active'] as bool;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _dio.get('/users/stats/');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final userDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasourceImpl(ref.watch(dioProvider));
});