import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/shift_request_model.dart';

class ShiftRequestCard extends StatelessWidget {
  const ShiftRequestCard({
    super.key,
    required this.request,
    required this.onReject,
    required this.onApprove,
  });

  final ShiftRequestModel request;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: [
              Icon(
                request.type == ShiftRequestType.changeShift
                    ? Icons.swap_horiz
                    : Icons.event_busy,
                color: request.type == ShiftRequestType.changeShift
                    ? AppColors.warning
                    : AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (request.workDate != null)
                Text(
                  _formatWorkDate(request.workDate!),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(request.description),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  child: const Text('Duyệt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatWorkDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return dateStr;
  }
}
