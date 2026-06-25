import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/pricing_policy_model.dart';

class PricingPolicyCard extends StatelessWidget {
  const PricingPolicyCard({
    super.key,
    required this.policy,
    required this.onApprove,
    required this.onReject,
    required this.onView,
    required this.onEdit,
  });

  final PricingPolicyModel policy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final bool isPending = policy.status == PricingPolicyStatus.pending;
    final bool isScheduled = policy.status == PricingPolicyStatus.scheduled;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  policy.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusBadge(
                label: policy.status.label,
                backgroundColor: policy.status.color.withValues(alpha: 0.12),
                foregroundColor: policy.status.color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(policy.subtitle),
          const SizedBox(height: 8),
          Text(
            policy.storeCount,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              if (isPending) ...<Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    child: const Text('Duyệt'),
                  ),
                ),
              ] else if (isScheduled) ...<Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    child: const Text('Sửa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onView,
                    child: const Text('Xem'),
                  ),
                ),
              ] else ...<Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: onView,
                    child: const Text('Xem'),
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
