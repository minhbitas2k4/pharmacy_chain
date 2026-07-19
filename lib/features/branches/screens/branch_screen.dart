import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/branch_controller.dart';
import '../services/branch_service.dart';
import '../widgets/branch_metric_card.dart';
import '../widgets/working_staff_card.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  late final BranchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BranchController(); // branchId auto-fetched from AuthController
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final dashboard = _controller.dashboard;
            return Column(
              children: <Widget>[
                const AppHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _controller.loadDashboard(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Chi nhánh',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Báo cáo doanh thu',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          _PeriodSelector(
                            selectedPeriod: _controller.selectedPeriod,
                            onPeriodChanged: _controller.setPeriod,
                          ),
                          const SizedBox(height: 12),
                          _DateNavigator(
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
                          const SizedBox(height: 12),
                          if (dashboard != null &&
                              dashboard.availableCounters.isNotEmpty)
                            _CounterFilter(
                              counters: dashboard.availableCounters,
                              selectedCounter: dashboard.selectedCounter,
                              onSelected: _controller.setCounter,
                            ),
                          const SizedBox(height: 20),
                          if (dashboard != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                dashboard.periodLabel,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.pharmaGreen,
                                    ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          if (_controller.isLoading && dashboard == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: LoadingView(
                                message: 'Đang tải chi nhánh...',
                              ),
                            )
                          else if (dashboard == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: Center(
                                child: Text('Không có dữ liệu'),
                              ),
                            )
                          else ...<Widget>[
                            Row(
                              children: <Widget>[
                                BranchMetricCard(
                                  title: 'Doanh thu',
                                  value: dashboard.revenueToday,
                                ),
                                const SizedBox(width: 12),
                                BranchMetricCard(
                                  title: 'Hóa đơn',
                                  value: dashboard.invoices,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AppCardSection(
                              title: dashboard.counterTitle,
                              summary: dashboard.counterSummary,
                              waiting: dashboard.waitingCustomers,
                            ),
                            if (dashboard.counterRevenue.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 16),
                              Text(
                                'Doanh thu theo quầy',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 12),
                              ...dashboard.counterRevenue.map(
                                (cr) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _CounterRevenueTile(
                                    counter: cr.counter,
                                    revenue: cr.revenue,
                                    invoiceCount: cr.invoiceCount,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'Nhân viên đang làm việc',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
if (dashboard.workingStaff.isEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Text(
        'Không có nhân viên nào đang làm việc',
        style: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
    ),
  )
else
  ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: dashboard.workingStaff.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (BuildContext context, int index) =>
        WorkingStaffCard(
          staff: dashboard.workingStaff[index],
        ),
  ),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dashboard.workingStaff.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (BuildContext context, int index) =>
                                    WorkingStaffCard(
                                      staff: dashboard.workingStaff[index],
                                    ),
                              ),
                          ],
                        ],
                      ),
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

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final periods = [
      (DashboardPeriod.day, 'Ngày'),
      (DashboardPeriod.week, 'Tuần'),
      (DashboardPeriod.month, 'Tháng'),
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

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.period,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  final DashboardPeriod period;
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

  String _formatDate(DashboardPeriod period, DateTime date) {
    switch (period) {
      case DashboardPeriod.day:
        return '${date.day}/${date.month}/${date.year}';
      case DashboardPeriod.week:
        return 'Tuần ${date.day}/${date.month}/${date.year}';
      case DashboardPeriod.month:
        return 'Tháng ${date.month}/${date.year}';
    }
  }
}

class _CounterFilter extends StatelessWidget {
  const _CounterFilter({
    required this.counters,
    required this.selectedCounter,
    required this.onSelected,
  });

  final List<String> counters;
  final String? selectedCounter;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final allOptions = ['Tất cả quầy', ...counters];
    final currentLabel = selectedCounter ?? 'Tất cả quầy';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.storefront, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentLabel,
                isExpanded: true,
                items: allOptions.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (value) {
                  if (value == 'Tất cả quầy') {
                    onSelected(null);
                  } else {
                    onSelected(value);
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

class _CounterRevenueTile extends StatelessWidget {
  const _CounterRevenueTile({
    required this.counter,
    required this.revenue,
    required this.invoiceCount,
  });

  final String counter;
  final String revenue;
  final int invoiceCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pharmaMint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront,
              color: AppColors.pharmaGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  counter,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '$invoiceCount hóa đơn',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            revenue,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.pharmaGreen,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class AppCardSection extends StatelessWidget {
  const AppCardSection({super.key, 
    required this.title,
    required this.summary,
    required this.waiting,
  });

  final String title;
  final String summary;
  final String waiting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(summary),
          const SizedBox(height: 4),
          Text(waiting),
        ],
      ),
    );
  }
}
