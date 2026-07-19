import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/drug_model.dart';

class DrugCatalogCard extends StatelessWidget {
  const DrugCatalogCard({
    super.key,
    required this.drug,
    required this.onUpdate,
  });

  final DrugModel drug;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final TextEditingController quantityController = TextEditingController();

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            drug.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text('Hoạt chất: ${drug.activeIngredient}'),
          Text('Hàm lượng: ${drug.strength}'),
          Text('Dạng bào chế: ${drug.dosageForm}'),
          Text('Quy cách: ${drug.packaging}'),
          Text(
            'Giá bán: ${drug.price}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số lượng / giá trị cập nhật',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final String value = quantityController.text.trim();
              if (value.isEmpty ||
                  int.tryParse(value) == null ||
                  int.parse(value) < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giá trị cập nhật phải là số không âm'),
                  ),
                );
                return;
              }
              onUpdate();
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }
}
