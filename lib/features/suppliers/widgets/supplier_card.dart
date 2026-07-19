import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_status.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/supplier_model.dart';

class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.onMessage,
    required this.onCall,
  });

  final SupplierModel supplier;
  final VoidCallback onMessage;
  final VoidCallback onCall;

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
                  supplier.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusBadge(
                label: supplier.status,
                backgroundColor: supplier.statusColor.withValues(alpha: 0.12),
                foregroundColor: supplier.statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Rating ${supplier.rating} • ${supplier.reviews} reviews'),
          const SizedBox(height: 10),
          Text('Contact: ${supplier.contact}'),
          const SizedBox(height: 4),
          Text('Last Transaction: ${supplier.lastTransaction}'),
          const SizedBox(height: 4),
          Text('Address: ${supplier.address}'),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onMessage,
                  child: const Text('Message'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onCall,
                  child: const Text('Call'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
