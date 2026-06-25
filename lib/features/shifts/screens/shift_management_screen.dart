import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
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
    _controller = ShiftController();
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
    final List<String> tabs = <String>['Lịch tuần', 'Đổi ca', 'Nghỉ phép'];
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
                          'Lịch ca tuần & yêu cầu đổi ca/nghỉ phép',
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
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(
                              message: 'Đang tải ca làm việc...',
                            ),
                          )
                        else if (_controller.selectedTab == 0)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _controller.weeklySchedule.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) =>
                                ShiftScheduleCard(
                                  shift: _controller.weeklySchedule[index],
                                ),
                          )
                        else if (_controller.selectedTab == 1)
                          Column(
                            children: _controller.changeRequests.map((request) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ShiftRequestCard(
                                  request: request,
                                  onReject: () {
                                    _controller.rejectRequest(request);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Đã từ chối yêu cầu đổi ca',
                                        ),
                                      ),
                                    );
                                  },
                                  onApprove: () {
                                    _controller.approveRequest(request);
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                          Column(
                            children: _controller.leaveRequests.map((request) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ShiftRequestCard(
                                  request: request,
                                  onReject: () {
                                    _controller.rejectRequest(request);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Đã từ chối yêu cầu nghỉ phép',
                                        ),
                                      ),
                                    );
                                  },
                                  onApprove: () {
                                    _controller.approveRequest(request);
                                    ScaffoldMessenger.of(context).showSnackBar(
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
