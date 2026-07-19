class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
    this.branchId,
    this.isLocked = false,
  });

  final String id;
  final String email;
  final String role;
  final String displayName;
  final String? branchId;
  final bool isLocked;

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'Dược sĩ',
      displayName: data['displayName']?.toString() ?? '',
      branchId: data['branchId']?.toString(),
      isLocked: data['isLocked'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': id,
      'email': email,
      'role': role,
      'displayName': displayName,
      'branchId': branchId,
      'isLocked': isLocked,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? displayName,
    String? branchId,
    bool? isLocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      branchId: branchId ?? this.branchId,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}