import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/audit_log_model.dart';

class AuditLogCard extends StatelessWidget {
  const AuditLogCard({super.key, required this.log});

  final AuditLogModel log;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  log.actionType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusBadge(
                label: log.status,
                backgroundColor: log.statusColor.withValues(alpha: 0.12),
                foregroundColor: log.statusColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Người thực hiện: ${log.actor}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Thời gian: ${log.time}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(log.description),
          const SizedBox(height: 8),
          Text(
            'Thiết bị: ${log.device} • Vị trí: ${log.location}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
