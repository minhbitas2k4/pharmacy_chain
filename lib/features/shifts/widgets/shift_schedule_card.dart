import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/shift_model.dart';

class ShiftScheduleCard extends StatelessWidget {
  const ShiftScheduleCard({super.key, required this.shift});

  final ShiftModel shift;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            backgroundColor: AppColors.pharmaMint,
            child: Icon(Icons.schedule, color: AppColors.pharmaGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              shift.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text('${shift.startTime} - ${shift.endTime}'),
        ],
      ),
    );
  }
}
