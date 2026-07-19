import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/schedule_controller.dart';
import '../widgets/month_calendar_mock.dart';
import '../widgets/schedule_filter_tabs.dart';
import '../widgets/schedule_form_dialog.dart';
import '../widgets/today_shift_card.dart';

class WorkScheduleScreen extends StatefulWidget {
  const WorkScheduleScreen({super.key});

  @override
  State<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  late final ScheduleController _controller;
  int _selectedDay = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    final branchId = AuthController().currentUser?.branchId ?? '';
    _controller = ScheduleController(branchId: branchId);
    _controller.loadSchedules();
    _controller.loadDropdownData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => ScheduleFormDialog(
        employees: _controller.employees,
        shifts: _controller.shifts,
        onSave: ({
          required String userId,
          required String shiftId,
          required String workDate,
          String? notes,
        }) async {
          await _controller.addSchedule(
            userId: userId,
            shiftId: shiftId,
            workDate: workDate,
            notes: notes,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm lịch làm việc')),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(dynamic scheduleModel) {
    showDialog<void>(
      context: context,
      builder: (ctx) => ScheduleFormDialog(
        isEdit: true,
        employees: _controller.employees,
        shifts: _controller.shifts,
        initialUserId: scheduleModel.userId,
        initialShiftId: scheduleModel.shiftId,
        initialDate: scheduleModel.workDate,
        initialNotes: scheduleModel.notes,
        onSave: ({
          required String userId,
          required String shiftId,
          required String workDate,
          String? notes,
        }) async {
          await _controller.updateSchedule(scheduleModel.scheduleId, {
            'shift_id': shiftId,
            'work_date': workDate,
            'notes': notes ?? '',
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật lịch')),
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(String scheduleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lịch làm việc'),
        content: const Text('Bạn có chắc muốn xóa lịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.deleteSchedule(scheduleId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa lịch làm việc')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final todayShifts = _controller.getSchedulesForDay(_selectedDay);

            final daysWithSchedules = <int>{};
            for (final schedule in _controller.schedules) {
              final date = DateTime.tryParse(schedule.workDate);
              if (date != null &&
                  date.month == now.month &&
                  date.year == now.year) {
                daysWithSchedules.add(date.day);
              }
            }

            return Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: _controller.isLoading
                      ? const LoadingView(message: 'Đang tải lịch...')
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Lịch làm việc',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tháng ${now.month}/${now.year}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 20),

                              // Employee filter dropdown
                              if (_controller.employees.isNotEmpty)
                                DropdownButtonFormField<String>(
                                  initialValue: _controller.selectedUserId,
                                  decoration: const InputDecoration(
                                    labelText: 'Lọc theo nhân viên',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('Tất cả nhân viên'),
                                    ),
                                    ..._controller.employees.map((e) {
                                      return DropdownMenuItem(
                                        value: e['uid'] as String?,
                                        child: Text(
                                            e['displayName'] as String? ?? ''),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    _controller.setUserFilter(value);
                                  },
                                ),
                              const SizedBox(height: 16),

                              ScheduleFilterTabs(
                                selectedIndex: _controller.selectedIndex,
                                onChanged: _controller.selectDate,
                              ),
                              const SizedBox(height: 16),
                              MonthCalendarMock(
                                daysInMonth: daysInMonth,
                                selectedDay: _selectedDay,
                                daysWithSchedules:
                                    daysWithSchedules.toList(),
                                onSelected: (day) {
                                  setState(() {
                                    _selectedDay = day;
                                  });
                                  _controller.selectDate(day);
                                },
                              ),
                              const SizedBox(height: 16),
                              TodayShiftCard(shifts: todayShifts),
                              const SizedBox(height: 12),

                              // Schedule entries for selected day with edit/delete
                              if (todayShifts.isNotEmpty) ...[
                                const Divider(),
                                Text(
                                  'Chi tiết ngày $_selectedDay',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                ...todayShifts.map((schedule) => Card(
                                      child: ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: AppColors.pharmaMint,
                                          child: Icon(Icons.schedule,
                                              color:
                                                  AppColors.pharmaDarkGreen),
                                        ),
                                        title: Text(schedule.userName ??
                                            schedule.userId),
                                        subtitle: Text(
                                          '${schedule.shiftName ?? schedule.shiftId}'
                                          '${schedule.notes != null && schedule.notes!.isNotEmpty ? ' • ${schedule.notes}' : ''}',
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (action) {
                                            if (action == 'edit') {
                                              _showEditDialog(schedule);
                                            } else if (action == 'delete') {
                                              _confirmDelete(
                                                  schedule.scheduleId);
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined,
                                                      size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Sửa'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline,
                                                      size: 18,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Xóa',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Thêm lịch'),
        backgroundColor: AppColors.pharmaGreen,
        foregroundColor: Colors.white,
      ),
    );
  }
}
