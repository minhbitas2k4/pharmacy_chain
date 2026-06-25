import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/dashboard_summary_model.dart';

class DashboardFilterTabs extends StatelessWidget {
  const DashboardFilterTabs({
    super.key,
    required this.selectedPeriod,
    required this.onSelected,
  });

  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: DashboardPeriod.values.map((DashboardPeriod period) {
        final bool isSelected = period == selectedPeriod;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: period == DashboardPeriod.month ? 0 : 8,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onSelected(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pharmaGreen : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.pharmaGreen
                        : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    period.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
