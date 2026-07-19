import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/employee_model.dart';

class EmployeeProfileCard extends StatelessWidget {
  const EmployeeProfileCard({
    super.key,
    required this.employee,
    required this.onView,
    required this.onUpdate,
  });

  final EmployeeModel employee;
  final VoidCallback onView;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: AppColors.pharmaMint,
                child: Text(
                  employee.displayName.isNotEmpty
                      ? employee.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.pharmaDarkGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.roleLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.email_outlined, text: employee.email),
          if (employee.phone != null && employee.phone!.isNotEmpty)
            _InfoRow(icon: Icons.phone_outlined, text: employee.phone!),
          if (employee.branchId != null && employee.branchId!.isNotEmpty)
            _InfoRow(icon: Icons.store_outlined, text: employee.branchId!),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onView,
                  child: const Text('Xem hồ sơ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onUpdate,
                  child: const Text('Cập nhật'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
