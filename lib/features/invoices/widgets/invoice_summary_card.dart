import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

class InvoiceSummaryCard extends StatelessWidget {
  const InvoiceSummaryCard({
    super.key,
    required this.total,
    required this.discount,
  });

  final double total;
  final double discount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tổng tiền: ${total.toStringAsFixed(0)}đ'),
          Text('Giảm giá: ${discount.toStringAsFixed(0)}đ'),
          Text('Thanh toán: ${(total - discount).toStringAsFixed(0)}đ'),
        ],
      ),
    );
  }
}
