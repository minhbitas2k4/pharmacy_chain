import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/drug_model.dart';

class DrugFilterTabs extends StatelessWidget {
  const DrugFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final DrugFilter selectedFilter;
  final ValueChanged<DrugFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: DrugFilter.values.map((DrugFilter filter) {
        final bool selected = filter == selectedFilter;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: filter == DrugFilter.vitamin ? 0 : 8,
            ),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: selected,
              onSelected: (_) => onChanged(filter),
              selectedColor: AppColors.pharmaGreen,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
