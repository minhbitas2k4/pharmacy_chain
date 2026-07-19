import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class MonthCalendarMock extends StatelessWidget {
  const MonthCalendarMock({
    super.key,
    required this.daysInMonth,
    required this.selectedDay,
    required this.daysWithSchedules,
    required this.onSelected,
  });

  final int daysInMonth;
  final int selectedDay;
  final List<int> daysWithSchedules;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final day = index + 1;
        final isSelected = day == selectedDay;
        final hasSchedule = daysWithSchedules.contains(day);
        return GestureDetector(
          onTap: () => onSelected(day),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.pharmaGreen
                  : hasSchedule
                      ? AppColors.pharmaMint
                      : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight:
                      hasSchedule ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
