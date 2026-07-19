import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../models/work_schedule_model.dart';

class TodayShiftCard extends StatelessWidget {
  const TodayShiftCard({super.key, required this.shifts});

  final List<WorkScheduleModel> shifts;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ca hôm nay',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (shifts.isEmpty)
            const Text(
              'Không có ca nào hôm nay',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...shifts.map(
              (shift) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${shift.userName ?? shift.userId} - ${shift.shiftName ?? shift.shiftId}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
