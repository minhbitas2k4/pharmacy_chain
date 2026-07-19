import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';

class StockProgressCard extends StatelessWidget {
  const StockProgressCard({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : current / total;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tiến độ kiểm hàng',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '$current/$total SKU',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }
}
