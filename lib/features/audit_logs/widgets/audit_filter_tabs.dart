import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/audit_log_model.dart';

class AuditFilterTabs extends StatelessWidget {
  const AuditFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final AuditFilter selectedFilter;
  final ValueChanged<AuditFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AuditFilter.values.map((AuditFilter filter) {
          final bool selected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: selected,
              onSelected: (_) => onChanged(filter),
              selectedColor: AppColors.pharmaGreen,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
