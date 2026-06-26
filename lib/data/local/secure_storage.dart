// lib/data/local/secure_storage.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyAccess   = 'flutter_shop_app:access';
  static const _keyRefresh  = 'flutter_shop_app:refresh';
  static const _keyUserId   = 'flutter_shop_app:user_id';
  static const _keyUsername = 'flutter_shop_app:username';
  static const _keyEmail    = 'flutter_shop_app:email';
  static const _keyIsStaff  = 'flutter_shop_app:is_staff';

  // ── Tokens ────────────────────────────────────────────────
  Future<String?> getAccess()  => _storage.read(key: _keyAccess);
  Future<String?> getRefresh() => _storage.read(key: _keyRefresh);

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _keyAccess,  value: access);
    await _storage.write(key: _keyRefresh, value: refresh);
  }

  Future<void> saveAccessToken(String access) =>
      _storage.write(key: _keyAccess, value: access);

  // ── Usuario ───────────────────────────────────────────────
  Future<void> saveUser({
    required int    id,
    required String username,
    required String email,
    required bool   isStaff,
  }) async {
    await _storage.write(key: _keyUserId,   value: id.toString());
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyEmail,    value: email);
    await _storage.write(key: _keyIsStaff,  value: isStaff.toString());
  }

  Future<Map<String, String>?> getUser() async {
    final id       = await _storage.read(key: _keyUserId);
    final username = await _storage.read(key: _keyUsername);
    final email    = await _storage.read(key: _keyEmail);
    final isStaff  = await _storage.read(key: _keyIsStaff);
    if (id == null || username == null) return null;
    return {
      'id':       id,
      'username': username,
      'email':    email ?? '',
      'is_staff': isStaff ?? 'false',
    };
  }

  Future<bool> isLoggedIn() async {
    final access = await getAccess();
    return access != null && access.isNotEmpty;
  }

  Future<void> clearSession() => _storage.deleteAll();
}

// Provider global de SecureStorage
final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorage());