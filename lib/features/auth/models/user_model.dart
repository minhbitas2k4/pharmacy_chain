class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
    this.branchId,
    this.phone,
    this.status,
  });

  final String id;
  final String email;
  final String role;
  final String displayName;
  final String? branchId;
  final String? phone;
  final String? status;

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      branchId: data['branchId'] as String?,
      phone: data['phone'] as String?,
      status: data['status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'role': role,
      'displayName': displayName,
      'branchId': branchId,
      'phone': phone,
      'status': status,
    };
  }
}