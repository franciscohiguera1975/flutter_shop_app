// lib/core/error/api_exception.dart

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int?   statusCode;
  final Map<String, dynamic>? fieldErrors;

  const ApiException(this.message, {this.statusCode, this.fieldErrors});

  factory ApiException.fromDioError(DioException error) {
    final response = error.response;
    final code     = response?.statusCode;

    if (response?.data == null) {
      return ApiException(
        error.message ?? 'Error de conexión',
        statusCode: code,
      );
    }

    final data = response!.data;

    // Mapa de errores de campo Django
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        return ApiException(data['detail'].toString(), statusCode: code);
      }
      if (data.containsKey('error')) {
        return ApiException(data['error'].toString(), statusCode: code);
      }
      if (data.containsKey('non_field_errors')) {
        final errors = data['non_field_errors'];
        final msg    = errors is List ? errors.first.toString() : errors.toString();
        return ApiException(msg, statusCode: code);
      }
      // Errores por campo
      final fieldErrors = <String, dynamic>{};
      String? firstMessage;
      data.forEach((key, value) {
        final msg = value is List ? value.first.toString() : value.toString();
        fieldErrors[key] = msg;
        firstMessage ??= '$key: $msg';
      });
      return ApiException(
        firstMessage ?? 'Error de validación',
        statusCode:  code,
        fieldErrors: fieldErrors,
      );
    }

    return ApiException(data.toString(), statusCode: code);
  }

  String? fieldError(String field) => fieldErrors?[field]?.toString();

  @override
  String toString() => message;
}