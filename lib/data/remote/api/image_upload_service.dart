// lib/data/remote/api/image_upload_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

/// Excepción lanzada cuando la subida de imagen falla.
class ImageUploadException implements Exception {
  const ImageUploadException(this.message);
  final String message;

  @override
  String toString() => 'ImageUploadException: $message';
}

/// Servicio para subir imágenes al API mediante multipart/form-data.
///
/// Usa el paquete `http` (no Dio) para construir [http.MultipartRequest]
/// y lee el token Bearer desde [FlutterSecureStorage].
class ImageUploadService {
  ImageUploadService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // -------------------------------------------------------------------------
  // Privados
  // -------------------------------------------------------------------------

  Future<String?> _readToken() async {
    return _storage.read(key: 'access_token');
  }

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
  };

  /// Sube un archivo al [uri] usando el campo de formulario [fieldName].
  /// Devuelve el cuerpo de la respuesta decodificado como Map.
  Future<Map<String, dynamic>> _upload({
    required Uri    uri,
    required String fieldName,
    required File   file,
  }) async {
    final token = await _readToken();
    if (token == null) {
      throw const ImageUploadException(
          'No autenticado. Inicia sesión primero.');
    }

    final mimeType = _mimeTypeFromPath(file.path);

    final request = http.MultipartRequest('PATCH', uri)
      ..headers.addAll(_authHeaders(token))
      ..files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: mimeType,
        ),
      );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw const ImageUploadException(
          'La solicitud tardó demasiado. Verifica tu conexión.',
        );
      },
    );

    final response = await http.Response.fromStream(streamedResponse);
    final body     = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body;
    }

    // Intentar extraer mensaje del API
    final detail = _extractError(body);
    throw ImageUploadException(detail);
  }

  String _extractError(Map<String, dynamic> body) {
    if (body.containsKey('detail')) return body['detail'].toString();
    if (body.containsKey('image')) {
      final v = body['image'];
      return v is List ? v.first.toString() : v.toString();
    }
    if (body.containsKey('avatar')) {
      final v = body['avatar'];
      return v is List ? v.first.toString() : v.toString();
    }
    return 'Error desconocido al subir la imagen.';
  }

  http.MediaType _mimeTypeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => http.MediaType('image', 'jpeg'),
      'png'           => http.MediaType('image', 'png'),
      'webp'          => http.MediaType('image', 'webp'),
      _               => http.MediaType('image', 'jpeg'),
    };
  }

  // -------------------------------------------------------------------------
  // API pública
  // -------------------------------------------------------------------------

  /// Sube la imagen de un producto (requiere usuario staff).
  ///
  /// Endpoint: PATCH /api/products/{productId}/
  /// Campo:    `image`
  ///
  /// Devuelve la URL absoluta de la imagen o null.
  Future<String?> uploadProductImage({
    required int  productId,
    required File file,
  }) async {
    final uri  = Uri.parse('${AppConfig.baseUrl}/products/$productId/');
    final body = await _upload(uri: uri, fieldName: 'image', file: file);
    return body['image_url'] as String?;
  }

  /// Sube el avatar del usuario autenticado.
  ///
  /// Endpoint: PATCH /api/users/profile/
  /// Campo:    `avatar`
  ///
  /// Devuelve la URL absoluta del avatar o null.
  Future<String?> uploadAvatar({required File file}) async {
    final uri  = Uri.parse('${AppConfig.baseUrl}/users/profile/');
    final body = await _upload(uri: uri, fieldName: 'avatar', file: file);
    return body['avatar_url'] as String?;
  }
}
