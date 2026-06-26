// lib/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/api_exception.dart';
import '../../data/local/secure_storage.dart';
import '../../data/remote/api/auth_remote_datasource.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/model/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDatasource _datasource;
  final SecureStorage        _storage;

  AuthNotifier(this._datasource, this._storage) : super(const AuthState.checking()) {
    _restoreSession();
  }

  // Restaurar sesión al iniciar la app
  Future<void> _restoreSession() async {
    try {
      final isLoggedIn = await _storage.isLoggedIn();
      if (!isLoggedIn) {
        state = const AuthState.unauthenticated();
        return;
      }
      final userData = await _storage.getUser();
      if (userData == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      final user = LoggedUser(
        id:       int.parse(userData['id']!),
        username: userData['username']!,
        email:    userData['email']!,
        isStaff:  userData['is_staff'] == 'true',
      );
      state = AuthState.authenticated(user);
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  // Login
  Future<void> login(String username, String password) async {
    state = const AuthState.checking();
    try {
      final user = await _datasource.login(username.trim(), password);
      state = AuthState.authenticated(user);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(e.message);
    } catch (e) {
      state = const AuthState.unauthenticated('Error inesperado. Intenta de nuevo.');
    }
  }

  // Registro
  Future<void> register(
    String username,
    String email,
    String password,
    String password2,
  ) async {
    state = const AuthState.checking();
    try {
      final user = await _datasource.register(
        username.trim(), email.trim(), password, password2,
      );
      state = AuthState.authenticated(user);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(e.message);
    } catch (e) {
      state = const AuthState.unauthenticated('Error inesperado. Intenta de nuevo.');
    }
  }

  // Logout
  Future<void> logout() async {
    await _datasource.logout();
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    if (state.isUnauthenticated && state.error != null) {
      state = const AuthState.unauthenticated();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authDatasourceProvider),
    ref.watch(secureStorageProvider),
  );
});