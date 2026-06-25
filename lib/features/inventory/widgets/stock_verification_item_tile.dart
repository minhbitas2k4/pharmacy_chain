import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/stock_verification_model.dart';

class StockVerificationItemTile extends StatelessWidget {
  const StockVerificationItemTile({super.key, required this.item});

  final StockVerificationModel item;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (item.status) {
      StockVerificationStatus.enough => AppColors.success,
      StockVerificationStatus.shortage => AppColors.warning,
      StockVerificationStatus.notScanned => AppColors.textSecondary,
    };
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            item.description,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
