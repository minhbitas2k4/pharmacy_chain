import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = ScheduleController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addShift() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController startController = TextEditingController();
    final TextEditingController endController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('+ Xếp ca mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nhân viên'),
            ),
            TextField(
              controller: startController,
              decoration: const InputDecoration(labelText: 'Giờ bắt đầu'),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(labelText: 'Giờ kết thúc'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        nameController.text.isNotEmpty &&
        startController.text.isNotEmpty &&
        endController.text.isNotEmpty) {
      _controller.addShift(
        nameController.text,
        startController.text,
        endController.text,
      );
    } else if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
    }
    nameController.dispose();
    startController.dispose();
    endController.dispose();
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Lịch làm việc',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tháng 7/2025 - CN Quận 1',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        ScheduleFilterTabs(
                          selectedIndex: _controller.selectedIndex,
                          onChanged: _controller.selectDate,
                        ),
                        const SizedBox(height: 16),
                        MonthCalendarMock(
                          days: _controller.month,
                          onSelected: (day) => _controller.selectDate(day),
                        ),
                        const SizedBox(height: 16),
                        TodayShiftCard(shifts: _controller.todayShifts),
                        const SizedBox(height: 16),
                        AppButton(text: '+ Xếp ca mới', onPressed: _addShift),
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
