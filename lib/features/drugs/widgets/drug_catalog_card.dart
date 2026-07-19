import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/drug_model.dart';

class DrugCatalogCard extends StatelessWidget {
  const DrugCatalogCard({
    super.key,
    required this.drug,
    required this.onEdit,
    required this.onDelete,
  });

  final DrugModel drug;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPrescription = drug.filter == DrugFilter.prescription;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  drug.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: drug.filter.label,
                backgroundColor: isPrescription
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                foregroundColor: isPrescription ? Colors.red : Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.science_outlined, 'Hoạt chất', drug.activeIngredient),
          _buildInfoRow(context, Icons.scale_outlined, 'Hàm lượng', drug.strength),
          _buildInfoRow(context, Icons.layers_outlined, 'Dạng bào chế', drug.dosageForm),
          _buildInfoRow(context, Icons.inventory_2_outlined, 'Quy cách', drug.packaging),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giá bán lẻ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    drug.price.endsWith('đ') ? drug.price : '${drug.price}đ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.pharmaGreen,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    tooltip: 'Sửa thông tin',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Xóa thuốc',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
