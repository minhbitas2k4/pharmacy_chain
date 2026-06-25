import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.onCheckout,
    required this.isLoading,
  });

  final double subtotal;
  final VoidCallback onCheckout;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tạm tính: ${subtotal.toStringAsFixed(0)}đ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : onCheckout,
            child: Text(isLoading ? 'Đang xử lý...' : 'Thanh toán'),
          ),
        ],
      ),
    );
  }
}
