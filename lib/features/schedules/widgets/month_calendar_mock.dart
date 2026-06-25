import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/work_schedule_model.dart';

class MonthCalendarMock extends StatelessWidget {
  const MonthCalendarMock({
    super.key,
    required this.days,
    required this.onSelected,
  });

  final List<WorkScheduleModel> days;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final item = days[index];
        return GestureDetector(
          onTap: () => onSelected(item.day),
          child: Container(
            decoration: BoxDecoration(
              color: item.isSelected ? AppColors.pharmaGreen : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                '${item.day}',
                style: TextStyle(
                  color: item.isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
