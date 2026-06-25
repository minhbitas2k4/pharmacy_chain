import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tổng tiền cần thanh toán',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${total.toStringAsFixed(0)}đ',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
