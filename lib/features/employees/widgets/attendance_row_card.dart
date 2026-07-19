import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/attendance_model.dart';

class AttendanceRowCard extends StatelessWidget {
  const AttendanceRowCard({
    super.key,
    required this.attendance,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onMarkAbsent,
  });

  final AttendanceModel attendance;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onMarkAbsent;

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã hoàn thành':
        return AppColors.success;
      case 'Đang làm':
        return AppColors.info;
      case 'Đi trễ':
        return AppColors.warning;
      case 'Vắng mặt':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Đã hoàn thành':
        return const Color(0xFFE8F6EC);
      case 'Đang làm':
        return const Color(0xFFE3F0FF);
      case 'Đi trễ':
        return const Color(0xFFFFF3D6);
      case 'Vắng mặt':
        return const Color(0xFFFDE8E8);
      default:
        return const Color(0xFFF0F0F0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = attendance.attendanceStatus;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.pharmaMint,
                child: Text(
                  (attendance.userName ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.pharmaDarkGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.userName ?? attendance.userId,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${attendance.shiftName ?? ''} (${attendance.shiftStartTime ?? ''} - ${attendance.shiftEndTime ?? ''})',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: statusText,
                backgroundColor: _statusBgColor(statusText),
                foregroundColor: _statusColor(statusText),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Time info
          Row(
            children: [
              _TimeChip(
                icon: Icons.login,
                label: 'Vào',
                time: attendance.checkInTime != null
                    ? _formatTime(attendance.checkInTime!)
                    : '--:--',
              ),
              const SizedBox(width: 12),
              _TimeChip(
                icon: Icons.logout,
                label: 'Ra',
                time: attendance.checkOutTime != null
                    ? _formatTime(attendance.checkOutTime!)
                    : '--:--',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          if (!attendance.isAbsent)
            Row(
              children: [
                if (!attendance.isCheckedIn) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCheckIn,
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Check-in'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pharmaGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMarkAbsent,
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Vắng'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ] else if (!attendance.isCheckedOut) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCheckOut,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Check-out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.icon,
    required this.label,
    required this.time,
  });

  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
