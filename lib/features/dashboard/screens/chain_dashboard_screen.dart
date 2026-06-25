import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_summary_model.dart';
import '../widgets/dashboard_filter_tabs.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/top_branch_card.dart';

class ChainDashboardScreen extends StatefulWidget {
  const ChainDashboardScreen({super.key});

  @override
  State<ChainDashboardScreen> createState() => _ChainDashboardScreenState();
}

class _ChainDashboardScreenState extends State<ChainDashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.loadSummary(DashboardPeriod.today);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTabChanged(DashboardPeriod period) async {
    await _controller.loadSummary(period);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final DashboardSummaryModel? summary = _controller.summary;

            return Column(
              children: <Widget>[
                const AppHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _controller.refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AppStrings.dashboardChainTitle,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppStrings.dashboardChainSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          DashboardFilterTabs(
                            selectedPeriod: _controller.selectedPeriod,
                            onSelected: _handleTabChanged,
                          ),
                          const SizedBox(height: 20),
                          if (_controller.isLoading && summary == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: LoadingView(
                                message: 'Đang tải dashboard...',
                              ),
                            )
                          else if (_controller.errorMessage != null &&
                              (summary == null || summary.hasError))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: ErrorView(
                                message: _controller.errorMessage!,
                                onRetry: _controller.refresh,
                              ),
                            )
                          else if (summary == null || summary.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: EmptyView(
                                title: 'Chưa có dữ liệu dashboard',
                                message:
                                    'Dữ liệu mock hiện tại chưa trả về nội dung cho tab này.',
                                onActionPressed: _controller.refresh,
                                actionLabel: 'Tải lại',
                              ),
                            )
                          else ...<Widget>[
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: summary.metrics.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 1.18,
                                  ),
                              itemBuilder: (BuildContext context, int index) {
                                return DashboardMetricCard(
                                  metric: summary.metrics[index],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Top chi nhánh',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return TopBranchCard(
                                  branch: summary.topBranches[index],
                                  rank: index + 1,
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemCount: summary.topBranches.length,
                            ),
                            if (summary.lastUpdated != null) ...<Widget>[
                              const SizedBox(height: 16),
                              Text(
                                'Cập nhật lần cuối: ${_formatTime(summary.lastUpdated!)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
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

  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
}
