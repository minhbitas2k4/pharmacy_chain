import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/branch_dashboard_model.dart';

class WorkingStaffCard extends StatelessWidget {
  const WorkingStaffCard({super.key, required this.staff});

  final WorkingStaffModel staff;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            backgroundColor: AppColors.pharmaMint,
            child: Icon(Icons.person, color: AppColors.pharmaGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  staff.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text('${staff.role} - ${staff.shift}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
