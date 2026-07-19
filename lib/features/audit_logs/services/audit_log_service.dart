import '../models/audit_log_model.dart';

class AuditLogService {
  Future<List<AuditLogModel>> fetchLogs() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return const <AuditLogModel>[
      AuditLogModel(
        actionType: 'Đăng nhập',
        actor: 'Admin',
        time: '09:12 - 25/06/2026',
        description: 'Admin đăng nhập thành công',
        status: 'success',
        filter: AuditFilter.login,
        device: 'Android App',
        location: 'Hà Nội',
      ),
      AuditLogModel(
        actionType: 'Cấu hình',
        actor: 'System Admin',
        time: '09:40 - 25/06/2026',
        description: 'Cập nhật cấu hình hệ thống',
        status: 'success',
        filter: AuditFilter.config,
        device: 'Web Admin',
        location: 'Đà Nẵng',
      ),
      AuditLogModel(
        actionType: 'Kho',
        actor: 'Kho trung tâm',
        time: '10:05 - 25/06/2026',
        description: 'Duyệt yêu cầu nhập kho PO-2025-0741',
        status: 'warning',
        filter: AuditFilter.inventory,
        device: 'iOS App',
        location: 'TP.HCM',
      ),
      AuditLogModel(
        actionType: 'Giá',
        actor: 'Pricing Admin',
        time: '10:24 - 25/06/2026',
        description: 'Cập nhật giá thuốc Amoxicillin 500mg',
        status: 'success',
        filter: AuditFilter.price,
        device: 'Web Admin',
        location: 'Hà Nội',
      ),
      AuditLogModel(
        actionType: 'Đăng nhập',
        actor: 'cashier01',
        time: '10:31 - 25/06/2026',
        description: 'Đăng nhập thất bại tài khoản cashier01',
        status: 'error',
        filter: AuditFilter.login,
        device: 'Android App',
        location: 'Bình Dương',
      ),
    ];
  }
}
