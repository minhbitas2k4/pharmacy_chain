class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
  });

  final String id;
  final String username;
  final String password;
  final String role;
  final String displayName;
}
