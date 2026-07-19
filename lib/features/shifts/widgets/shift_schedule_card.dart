import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../models/shift_model.dart';

class ShiftScheduleCard extends StatelessWidget {
  const ShiftScheduleCard({
    super.key,
    required this.shift,
    this.showDate = false,
  });

  final ShiftModel shift;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: _statusColor,
            child: Icon(_statusIcon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (shift.shiftName.isNotEmpty)
                  Text(
                    shift.shiftName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (showDate && shift.workDate.isNotEmpty)
                  Text(
                    _formatWorkDate(shift.workDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${shift.startTime} - ${shift.endTime}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _statusColor {
    switch (shift.status) {
      case 'active':
        return AppColors.pharmaGreen;
      case 'pending_change':
        return AppColors.warning;
      case 'pending_leave':
        return AppColors.info;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'handed_over':
        return AppColors.textSecondary;
      default:
        return AppColors.pharmaGreen;
    }
  }

  IconData get _statusIcon {
    switch (shift.status) {
      case 'active':
        return Icons.check;
      case 'pending_change':
        return Icons.swap_horiz;
      case 'pending_leave':
        return Icons.event_busy;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'handed_over':
        return Icons.handshake;
      default:
        return Icons.schedule;
    }
  }

  String get _statusLabel {
    switch (shift.status) {
      case 'active':
        return 'Đang làm';
      case 'pending_change':
        return 'Đổi ca';
      case 'pending_leave':
        return 'Nghỉ phép';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      case 'handed_over':
        return 'Đã bàn giao';
      default:
        return '';
    }
  }

  String _formatWorkDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return dateStr;
  }
}
