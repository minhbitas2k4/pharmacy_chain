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
              Expanded(
                child: Text(
                  employee.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const StatusBadge(label: 'Đang làm việc'),
            ],
          ),
          const SizedBox(height: 8),
          Text(employee.title),
          Text('CMND/CCCD: ${employee.cccd}'),
          Text('SDT: ${employee.phone}'),
          Text('Chứng chỉ hành nghề: ${employee.license}'),
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
