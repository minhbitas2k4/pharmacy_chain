class EmployeeModel {
  const EmployeeModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.phone,
    this.branchId,
    this.status,
  });

  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String? phone;
  final String? branchId;
  final String? status;

  bool get isActive {
    final s = (status ?? '').toLowerCase();
    return s == 'active' || s == 'ACTIVE';
  }

  String get roleLabel {
    switch (role) {
      case 'system_admin':
        return 'Quản trị hệ thống';
      case 'chain_manager':
        return 'Quản lý chuỗi';
      case 'branch_manager':
        return 'Quản lý chi nhánh';
      case 'pharmacist':
        return 'Dược sĩ';
      case 'cashier':
        return 'Thu ngân';
      case 'warehouse_staff':
        return 'Nhân viên kho';
      case 'hr_admin':
        return 'Nhân sự / Admin';
      default:
        return 'Nhân viên';
    }
  }

  String get statusLabel => isActive ? 'Đang làm việc' : 'Đã nghỉ';

  factory EmployeeModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return EmployeeModel(
      uid: id ?? data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? '',
      phone: data['phone'] as String?,
      branchId: data['branchId'] as String?,
      status: data['status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'phone': phone,
      'branchId': branchId,
      'status': status,
    };
  }
}
