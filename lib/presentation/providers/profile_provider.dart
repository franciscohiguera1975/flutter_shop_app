// lib/presentation/providers/profile_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/api_exception.dart';
import '../../data/remote/api/dio_client.dart';
import '../../domain/model/user_profile.dart';

/// Obtiene el perfil completo del usuario autenticado desde /api/users/profile/.
/// Incluye [avatarUrl], firstName, lastName y demás campos de [UserProfile].
///
/// Usar `ref.invalidate(profileProvider)` después de subir un avatar
/// para forzar la recarga y mostrar la imagen actualizada.
final profileProvider = FutureProvider.autoDispose<UserProfile>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get('/users/profile/');
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw ApiException.fromDioError(e);
  }
});
