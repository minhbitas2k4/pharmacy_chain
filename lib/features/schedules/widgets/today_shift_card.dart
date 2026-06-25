import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../shifts/models/shift_model.dart';

class TodayShiftCard extends StatelessWidget {
  const TodayShiftCard({super.key, required this.shifts});

  final List<ShiftModel> shifts;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ca hôm nay (10/07)',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...shifts.map(
            (shift) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${shift.name} ${shift.time}'),
            ),
          ),
        ],
      ),
    );
  }
}
