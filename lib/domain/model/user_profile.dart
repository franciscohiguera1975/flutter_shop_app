// lib/domain/model/user_profile.dart

/// Modelo de dominio para el perfil del usuario autenticado.
/// Distinto de [User] (lista admin) — incluye avatarUrl.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    this.avatarUrl,
  });

  final int     id;
  final String  username;
  final String  email;
  final String  firstName;
  final String  lastName;
  final bool    isStaff;
  final String? avatarUrl; // URL absoluta o null

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id:         j['id']          as int,
    username:   j['username']    as String,
    email:      j['email']       as String,
    firstName:  j['first_name']  as String? ?? '',
    lastName:   j['last_name']   as String? ?? '',
    isStaff:    j['is_staff']    as bool?   ?? false,
    avatarUrl:  j['avatar_url']  as String?,
  );
}
