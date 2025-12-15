enum UserRole { admin, teacher}

class AuthUser {
  final String id;
  final String name;
  final UserRole role;

  AuthUser({
    required this.id,
    required this.name,
    required this.role,
  });
}