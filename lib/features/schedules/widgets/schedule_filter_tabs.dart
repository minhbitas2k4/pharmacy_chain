import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ScheduleFilterTabs extends StatelessWidget {
  const ScheduleFilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Tháng 7', 'Tuần này', 'Theo NV'];
    return Row(
      children: List.generate(labels.length, (index) {
        final selected = selectedIndex == index;
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
