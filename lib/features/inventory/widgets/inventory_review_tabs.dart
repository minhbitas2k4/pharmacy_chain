import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class InventoryReviewTabs extends StatelessWidget {
  const InventoryReviewTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.pendingCount = 0,
    this.approvedCount = 0,
    this.rejectedCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>[
      'Chờ duyệt ($pendingCount)',
      'Đã duyệt ($approvedCount)',
      'Từ chối ($rejectedCount)',
    ];
    return Row(
      children: List<Widget>.generate(labels.length, (int index) {
        final bool selected = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(labels[index]),
              selected: selected,
              onSelected: (_) => onChanged(index),
              selectedColor: AppColors.pharmaGreen,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}
