// lib/domain/model/auth_models.dart

class AuthTokens {
  final String access;
  final String refresh;
  const AuthTokens({required this.access, required this.refresh});
}

class LoggedUser {
  final int    id;
  final String username;
  final String email;
  final bool   isStaff;

  const LoggedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
  });

  factory LoggedUser.fromMap(Map<String, dynamic> map) => LoggedUser(
    id:       map['user_id'] as int,
    username: map['username'] as String,
    email:    map['email']    as String,
    isStaff:  map['is_staff'] as bool,
  );
}