import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/shift_controller.dart';
import '../widgets/shift_request_card.dart';
import '../widgets/shift_schedule_card.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  late final ShiftController _controller;

  @override
  void initState() {
    super.initState();
    final branchId = AuthController().currentUser?.branchId ?? '';
    _controller = ShiftController(branchId: branchId);
    _controller.loadSchedule();
    _controller.loadRequests();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>['Lịch ca', 'Đổi ca', 'Nghỉ phép'];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Column(
              children: <Widget>[
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Quản lý ca làm việc',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Xem lịch ca theo ngày, tuần, tháng',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: List<Widget>.generate(tabs.length, (
                            int index,
                          ) {
                            final bool selected =
                                index == _controller.selectedTab;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == tabs.length - 1 ? 0 : 8,
                                ),
                                child: ChoiceChip(
                                  label: Text(tabs[index]),
                                  selected: selected,
                                  onSelected: (_) =>
                                      _controller.selectTab(index),
                                  selectedColor: AppColors.pharmaGreen,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_controller.selectedTab == 0) ...[
                          const SizedBox(height: 16),
                          _ShiftPeriodSelector(
                            selectedPeriod: _controller.selectedPeriod,
                            onPeriodChanged: _controller.setPeriod,
                          ),
                          const SizedBox(height: 12),
                          _ShiftDateNavigator(
                            period: _controller.selectedPeriod,
                            selectedDate: _controller.selectedDate,
                            onPrevious: _controller.previousPeriod,
                            onNext: _controller.nextPeriod,
                            onPickDate: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _controller.selectedDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) _controller.setDate(picked);
                            },
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              _controller.periodLabel,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.pharmaGreen,
                                  ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(
                              message: 'Đang tải ca làm việc...',
                            ),
                          )
                        else if (_controller.selectedTab == 0)
                          _controller.weeklySchedule.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 48,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Không có ca nào trong khoảng này',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _controller.weeklySchedule.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          ShiftScheduleCard(
                                            shift: _controller
                                                .weeklySchedule[index],
                                            showDate:
                                                _controller.selectedPeriod !=
                                                    ShiftPeriod.day,
                                          ),
                                )
                        else if (_controller.selectedTab == 1)
                          _controller.changeRequests.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Không có yêu cầu đổi ca',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children:
                                      _controller.changeRequests.map((
                                        request,
                                      ) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: ShiftRequestCard(
                                            request: request,
                                            onReject: () {
                                              _controller
                                                  .rejectRequest(request);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Đã từ chối yêu cầu đổi ca',
                                                  ),
                                                ),
                                              );
                                            },
                                            onApprove: () {
                                              _controller
                                                  .approveRequest(request);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Đã duyệt yêu cầu đổi ca',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }).toList(),
                                )
                        else
                          _controller.leaveRequests.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Không có yêu cầu nghỉ phép',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children:
                                      _controller.leaveRequests.map((
                                        request,
                                      ) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: ShiftRequestCard(
                                            request: request,
                                            onReject: () {
                                              _controller
                                                  .rejectRequest(request);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Đã từ chối yêu cầu nghỉ phép',
                                                  ),
                                                ),
                                              );
                                            },
                                            onApprove: () {
                                              _controller
                                                  .approveRequest(request);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Đã duyệt yêu cầu nghỉ phép',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }).toList(),
                                ),
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

class _ShiftPeriodSelector extends StatelessWidget {
  const _ShiftPeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final ShiftPeriod selectedPeriod;
  final ValueChanged<ShiftPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final periods = [
      (ShiftPeriod.day, 'Ngày'),
      (ShiftPeriod.week, 'Tuần'),
      (ShiftPeriod.month, 'Tháng'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: periods.map((p) {
          final selected = p.$1 == selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(p.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.pharmaGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  p.$2,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ShiftDateNavigator extends StatelessWidget {
  const _ShiftDateNavigator({
    required this.period,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  final ShiftPeriod period;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onPickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(period, selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(ShiftPeriod period, DateTime date) {
    switch (period) {
      case ShiftPeriod.day:
        return '${date.day}/${date.month}/${date.year}';
      case ShiftPeriod.week:
        return 'Tuần ${date.day}/${date.month}/${date.year}';
      case ShiftPeriod.month:
        return 'Tháng ${date.month}/${date.year}';
    }
  }
}
