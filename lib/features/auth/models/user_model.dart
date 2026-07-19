class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
    this.branchId,
    this.isLocked = false,
    this.phone,
    this.status,
  });

  final String id;
  final String email;
  final String role;
  final String displayName;
  final String? branchId;
  final bool isLocked;
  final String? phone;
  final String? status;

  factory UserModel.fromMap(Map<String, dynamic> data) {
    final rawRole = data['role'] as String? ?? '';
    return UserModel(
      id: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: normalizeRole(rawRole),
      displayName: data['displayName'] as String? ?? '',
      branchId: data['branchId'] as String?,
      isLocked: data['isLocked'] == true,
      phone: data['phone'] as String?,
      status: data['status'] as String?,
    );
  }

  static String normalizeRole(String role) {
    final cleaned = role.trim().toLowerCase();
    switch (cleaned) {
      case 'system_admin':
      case 'quản trị hệ thống':
        return 'system_admin';
      case 'chain_manager':
      case 'quản lý chuỗi':
        return 'chain_manager';
      case 'branch_manager':
      case 'quản lý chi nhánh':
        return 'branch_manager';
      case 'purchasing_manager':
      case 'quản lý mua hàng':
      case 'quản lý nhập hàng':
        return 'purchasing_manager';
      case 'pharmacist':
      case 'dược sĩ':
        return 'pharmacist';
      case 'cashier':
      case 'thu ngân':
        return 'cashier';
      case 'warehouse_staff':
      case 'nhân viên kho':
        return 'warehouse_staff';
      case 'hr_admin':
      case 'nhân sự':
      case 'nhân sự / admin':
        return 'hr_admin';
      default:
        return cleaned.isEmpty ? 'pharmacist' : cleaned;
    }
  }

  static String getRoleDisplayName(String roleKey) {
    switch (roleKey) {
      case 'system_admin': return 'Quản trị hệ thống';
      case 'chain_manager': return 'Quản lý chuỗi';
      case 'branch_manager': return 'Quản lý chi nhánh';
      case 'purchasing_manager': return 'Quản lý mua hàng';
      case 'pharmacist': return 'Dược sĩ';
      case 'cashier': return 'Thu ngân';
      case 'warehouse_staff': return 'Nhân viên kho';
      case 'hr_admin': return 'Nhân sự';
      default: return roleKey;
    }
  }

  static String getRoleKey(String displayName) {
    switch (displayName) {
      case 'Quản trị hệ thống': return 'system_admin';
      case 'Quản lý chuỗi': return 'chain_manager';
      case 'Quản lý chi nhánh': return 'branch_manager';
      case 'Quản lý mua hàng':
      case 'Quản lý nhập hàng': return 'purchasing_manager';
      case 'Dược sĩ': return 'pharmacist';
      case 'Thu ngân': return 'cashier';
      case 'Nhân viên kho': return 'warehouse_staff';
      case 'Nhân sự': return 'hr_admin';
      default: return displayName;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'role': role,
      'displayName': displayName,
      'branchId': branchId,
      'isLocked': isLocked,
      'phone': phone,
      'status': status,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? displayName,
    String? branchId,
    bool? isLocked,
    String? phone,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      branchId: branchId ?? this.branchId,
      isLocked: isLocked ?? this.isLocked,
      phone: phone ?? this.phone,
      status: status ?? this.status,
    );
  }
}