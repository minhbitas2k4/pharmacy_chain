import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/employee_controller.dart';
import '../models/employee_model.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({
    super.key,
    required this.employee,
    required this.controller,
  });

  final EmployeeModel employee;
  final EmployeeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết nhân viên'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar & Name header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.pharmaMint,
                    child: Text(
                      employee.displayName.isNotEmpty
                          ? employee.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.pharmaDarkGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    employee.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(
                    label: employee.statusLabel,
                    backgroundColor: employee.isActive
                        ? AppColors.pharmaMint
                        : const Color(0xFFFDE8E8),
                    foregroundColor: employee.isActive
                        ? AppColors.pharmaDarkGreen
                        : AppColors.error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin cá nhân',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Divider(height: 24),
                  _DetailRow(label: 'Họ và tên', value: employee.displayName),
                  _DetailRow(label: 'Email', value: employee.email),
                  _DetailRow(
                      label: 'Số điện thoại',
                      value: employee.phone ?? 'Chưa cập nhật'),
                  _DetailRow(label: 'Vai trò', value: employee.roleLabel),
                  _DetailRow(
                      label: 'Chi nhánh',
                      value: employee.branchId ?? 'Toàn hệ thống'),
                  _DetailRow(label: 'Trạng thái', value: employee.statusLabel),
                  _DetailRow(label: 'UID', value: employee.uid),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmployeeFormScreen(
                            employee: employee,
                            controller: controller,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Chỉnh sửa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(employee.isActive
                              ? 'Vô hiệu hóa nhân viên'
                              : 'Kích hoạt nhân viên'),
                          content: Text(employee.isActive
                              ? 'Bạn có chắc muốn vô hiệu hóa ${employee.displayName}?'
                              : 'Bạn có chắc muốn kích hoạt lại ${employee.displayName}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: employee.isActive
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                              child: Text(
                                  employee.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await controller.toggleStatus(
                            employee.uid, employee.status ?? 'ACTIVE');
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(employee.isActive
                                  ? 'Đã vô hiệu hóa ${employee.displayName}'
                                  : 'Đã kích hoạt ${employee.displayName}'),
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      employee.isActive
                          ? Icons.person_off_outlined
                          : Icons.person_add_outlined,
                    ),
                    label: Text(
                        employee.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          employee.isActive ? AppColors.error : AppColors.success,
                      side: BorderSide(
                        color: employee.isActive
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
