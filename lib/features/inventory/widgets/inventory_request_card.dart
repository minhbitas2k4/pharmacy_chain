import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/inventory_request_model.dart';

class InventoryRequestCard extends StatelessWidget {
  const InventoryRequestCard({
    super.key,
    required this.request,
    required this.onReject,
    required this.onApprove,
    required this.onView,
  });

  final InventoryRequestModel request;
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (request.status) {
      InventoryRequestStatus.pending => AppColors.warning,
      InventoryRequestStatus.approved => AppColors.success,
      InventoryRequestStatus.rejected => AppColors.error,
    };

    final String statusLabel = switch (request.status) {
      InventoryRequestStatus.pending => 'Chờ duyệt',
      InventoryRequestStatus.approved => 'Đã duyệt',
      InventoryRequestStatus.rejected => 'Từ chối',
    };

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  request.code,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusBadge(
                label: statusLabel,
                backgroundColor: statusColor.withValues(alpha: 0.12),
                foregroundColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Loại: ${request.title}'),
          Text(request.subtitle),
          const SizedBox(height: 4),
          Text(request.date),
          const SizedBox(height: 4),
          Text(request.itemsLabel),
          if (request.totalLabel.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Tổng: ${request.totalLabel}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onView,
                  child: const Text('Xem chi tiết'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  child: const Text('Duyệt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
