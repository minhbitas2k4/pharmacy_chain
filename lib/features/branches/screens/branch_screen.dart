import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/branch_controller.dart';
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
    final branchId = AuthController().currentUser?.branchId ?? '';
    _controller = BranchController(branchId: branchId);
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
                    onRefresh: () async {
                      _controller.loadDashboard();
                    },
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
                            'Báo cáo nhanh hôm nay',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          if (_controller.isLoading || dashboard == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: LoadingView(
                                message: 'Đang tải chi nhánh...',
                              ),
                            )
                          else ...<Widget>[
                            Row(
                              children: <Widget>[
                                BranchMetricCard(
                                  title: 'Doanh thu hôm nay',
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
                            const SizedBox(height: 16),
                            Text(
                              'Nhân viên đang làm việc',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
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

class AppCardSection extends StatelessWidget {
  const AppCardSection({
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
