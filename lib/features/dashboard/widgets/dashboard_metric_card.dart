import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/dashboard_summary_model.dart';

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({super.key, required this.metric});

  final DashboardMetricModel metric;

  @override
  Widget build(BuildContext context) {
    final bool hasLabel = metric.changeLabel.isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metric.icon, color: metric.color),
          ),
          const SizedBox(height: 14),
          Text(
            metric.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                metric.change,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: metric.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasLabel) ...<Widget>[
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    metric.changeLabel,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
