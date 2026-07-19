import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/drug_model.dart';

class DrugLookupCard extends StatelessWidget {
  const DrugLookupCard({
    super.key,
    required this.drug,
    required this.onAddToCart,
    required this.onInteraction,
  });

  final DrugModel drug;
  final VoidCallback onAddToCart;
  final VoidCallback onInteraction;

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
                  drug.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const StatusBadge(label: 'Kê đơn'),
            ],
          ),
          const SizedBox(height: 8),
          Text('Hoạt chất: Amoxicillin trihydrate'),
          Text('Công dụng: Điều trị nhiễm khuẩn đường hô hấp, tiết niệu, da'),
          Text('Liều dùng: 500mg x 3 lần/ngày, uống sau bữa ăn'),
          Text('Vị trí kho: Kệ B-12'),
          Text(
            'Tồn kho: 320 hộp',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onInteraction,
                  child: const Text('Tương tác'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAddToCart,
                  child: const Text('+ Thêm vào đơn'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
