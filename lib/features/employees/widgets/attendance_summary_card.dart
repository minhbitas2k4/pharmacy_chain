import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';

class AttendanceSummaryCard extends StatelessWidget {
  const AttendanceSummaryCard({
    super.key,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.pendingCount,
  });

  final int presentCount;
  final int lateCount;
  final int absentCount;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê chấm công',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(
                icon: Icons.check_circle_outlined,
                label: 'Có mặt',
                count: presentCount,
                color: AppColors.success,
              ),
              _StatItem(
                icon: Icons.access_time,
                label: 'Đi trễ',
                count: lateCount,
                color: AppColors.warning,
              ),
              _StatItem(
                icon: Icons.cancel_outlined,
                label: 'Vắng',
                count: absentCount,
                color: AppColors.error,
              ),
              _StatItem(
                icon: Icons.pending_outlined,
                label: 'Chờ',
                count: pendingCount,
                color: AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
