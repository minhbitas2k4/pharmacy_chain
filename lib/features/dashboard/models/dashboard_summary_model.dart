import 'package:flutter/material.dart';

enum DashboardPeriod { today, week, month }

extension DashboardPeriodX on DashboardPeriod {
  String get label {
    switch (this) {
      case DashboardPeriod.today:
        return 'Hôm nay';
      case DashboardPeriod.week:
        return 'Tuần';
      case DashboardPeriod.month:
        return 'Tháng';
    }
  }
}

class DashboardMetricModel {
  const DashboardMetricModel({
    required this.title,
    required this.value,
    required this.change,
    required this.changeLabel,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String change;
  final String changeLabel;
  final IconData icon;
  final Color color;
}

class TopBranchModel {
  const TopBranchModel({
    required this.name,
    required this.city,
    required this.revenue,
  });

  final String name;
  final String city;
  final String revenue;
}

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.period,
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.topBranches,
    this.isLoading = false,
    this.hasError = false,
    this.emptyMessage,
    this.lastUpdated,
  });

  final DashboardPeriod period;
  final String title;
  final String subtitle;
  final List<DashboardMetricModel> metrics;
  final List<TopBranchModel> topBranches;
  final bool isLoading;
  final bool hasError;
  final String? emptyMessage;
  final DateTime? lastUpdated;

  bool get isEmpty => metrics.isEmpty || topBranches.isEmpty;

  factory DashboardSummaryModel.empty({
    required DashboardPeriod period,
    String title = 'Dashboard Chuỗi',
    String subtitle = 'Doanh thu & hiệu suất thời gian thực',
    String message = 'Không có dữ liệu để hiển thị.',
  }) {
    return DashboardSummaryModel(
      period: period,
      title: title,
      subtitle: subtitle,
      metrics: const <DashboardMetricModel>[],
      topBranches: const <TopBranchModel>[],
      emptyMessage: message,
    );
  }

  factory DashboardSummaryModel.error({
    required DashboardPeriod period,
    String title = 'Dashboard Chuỗi',
    String subtitle = 'Doanh thu & hiệu suất thời gian thực',
  }) {
    return DashboardSummaryModel(
      period: period,
      title: title,
      subtitle: subtitle,
      metrics: const <DashboardMetricModel>[],
      topBranches: const <TopBranchModel>[],
      hasError: true,
    );
  }
}
