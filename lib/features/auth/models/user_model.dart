class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
    this.branchId,
  });

  final String id;
  final String email;
  final String role;
  final String displayName;
  final String? branchId;

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid'],
      email: data['email'],
      role: data['role'],
      displayName: data['displayName'],
      branchId: data['branchId'],
    );
  }
}