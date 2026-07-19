import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/warehouse_alert_model.dart';

class WarehouseAlertCard extends StatelessWidget {
  const WarehouseAlertCard({
    super.key,
    required this.alert,
    required this.onCreateOrder,
  });

  final WarehouseAlertModel alert;
  final VoidCallback onCreateOrder;

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
                  alert.productName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusBadge(label: alert.badgeLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text('Lô: ${alert.batchCode} • ${alert.quantity} hộp'),
          const SizedBox(height: 4),
          Text('HSD: ${alert.expiryDate}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onCreateOrder,
            child: const Text('+ Tạo đơn nhập'),
          ),
        ],
      ),
    );
  }
}
