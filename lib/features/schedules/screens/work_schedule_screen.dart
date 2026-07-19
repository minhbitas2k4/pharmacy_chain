import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/schedule_controller.dart';
import '../widgets/month_calendar_mock.dart';
import '../widgets/schedule_filter_tabs.dart';
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final todayShifts = _controller.getSchedulesForDay(_selectedDay);

    final daysWithSchedules = <int>{};
    for (final schedule in _controller.schedules) {
      final date = DateTime.tryParse(schedule.workDate);
      if (date != null && date.month == now.month && date.year == now.year) {
        daysWithSchedules.add(date.day);
      }
    }

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
                  child: SingleChildScrollView(
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
                        ScheduleFilterTabs(
                          selectedIndex: _controller.selectedIndex,
                          onChanged: _controller.selectDate,
                        ),
                        const SizedBox(height: 16),
                        MonthCalendarMock(
                          daysInMonth: daysInMonth,
                          selectedDay: _selectedDay,
                          daysWithSchedules: daysWithSchedules.toList(),
                          onSelected: (day) {
                            setState(() {
                              _selectedDay = day;
                            });
                            _controller.selectDate(day);
                          },
                        ),
                        const SizedBox(height: 16),
                        TodayShiftCard(shifts: todayShifts),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
