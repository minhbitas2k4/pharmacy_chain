import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/empty_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/attendance_summary_card.dart';
import '../widgets/attendance_row_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late final AttendanceController _controller;

  @override
  void initState() {
    super.initState();
    final branchId = AuthController().currentUser?.branchId ?? '';
    _controller = AttendanceController(branchId: branchId);
    _controller.loadAttendance();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_controller.selectedDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      final dateStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _controller.changeDate(dateStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: _controller.isLoading
                      ? const LoadingView(message: 'Đang tải chấm công...')
                      : _buildContent(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final dateParts = _controller.selectedDate.split('-');
    final displayDate = dateParts.length == 3
        ? '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}'
        : _controller.selectedDate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Chấm công',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Quản lý chấm công nhân viên',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Date selector
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.pharmaGreen),
                  const SizedBox(width: 12),
                  Text(
                    displayDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Summary card
          AttendanceSummaryCard(
            presentCount: _controller.presentCount,
            lateCount: _controller.lateCount,
            absentCount: _controller.absentCount,
            pendingCount: _controller.pendingCount,
          ),
          const SizedBox(height: 20),

          // Attendance list
          Text(
            'Danh sách (${_controller.records.length})',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          if (_controller.records.isEmpty)
            const EmptyView(
              title: 'Không có dữ liệu',
              message: 'Không có lịch làm việc cho ngày này',
              icon: Icons.event_busy_outlined,
            )
          else
            ..._controller.records.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AttendanceRowCard(
                  attendance: record,
                  onCheckIn: () async {
                    await _controller.checkIn(record.scheduleId);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Đã check-in ${record.userName ?? record.userId}'),
                      ),
                    );
                  },
                  onCheckOut: () async {
                    await _controller.checkOut(record.scheduleId);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Đã check-out ${record.userName ?? record.userId}'),
                      ),
                    );
                  },
                  onMarkAbsent: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Đánh dấu vắng mặt'),
                        content: Text(
                            'Xác nhận ${record.userName ?? record.userId} vắng mặt?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: const Text('Xác nhận'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _controller.markAbsent(record.scheduleId);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Đã đánh dấu ${record.userName ?? record.userId} vắng mặt'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
