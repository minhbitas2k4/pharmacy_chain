import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/dashboard_summary_model.dart';

class DashboardService {
  DashboardService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<DashboardSummaryModel> fetchSummary(DashboardPeriod period) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('dashboard')
        .doc(period.name)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return _fallbackSummary(period);
    }

    final Map<String, dynamic> data = snapshot.data()!;
    return DashboardSummaryModel(
      period: period,
      title: data['title']?.toString() ?? 'Dashboard Chuỗi',
      subtitle: data['subtitle']?.toString() ?? 'Doanh thu & hiệu suất thời gian thực',
      metrics: _buildMetrics(data['metrics'] as List<dynamic>? ?? const <dynamic>[]),
      topBranches: _buildTopBranches(data['topBranches'] as List<dynamic>? ?? const <dynamic>[]),
      lastUpdated: DateTime.tryParse(data['lastUpdated']?.toString() ?? ''),
    );
  }

  List<DashboardMetricModel> _buildMetrics(List<dynamic> values) {
    return values.map((dynamic item) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(item as Map<String, dynamic>);
      return DashboardMetricModel(
        title: map['title']?.toString() ?? '',
        value: map['value']?.toString() ?? '',
        change: map['change']?.toString() ?? '',
        changeLabel: map['changeLabel']?.toString() ?? '',
        icon: Icons.payments_rounded,
        color: AppColors.success,
      );
    }).toList();
  }

  List<TopBranchModel> _buildTopBranches(List<dynamic> values) {
    return values.map((dynamic item) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(item as Map<String, dynamic>);
      return TopBranchModel(
        name: map['name']?.toString() ?? '',
        city: map['city']?.toString() ?? '',
        revenue: map['revenue']?.toString() ?? '',
      );
    }).toList();
  }

  DashboardSummaryModel _fallbackSummary(DashboardPeriod period) {
    switch (period) {
      case DashboardPeriod.today:
        return _todaySummary();
      case DashboardPeriod.week:
        return _weekSummary();
      case DashboardPeriod.month:
        return _monthSummary();
    }
  }

  DashboardSummaryModel _todaySummary() {
    return DashboardSummaryModel(
      period: DashboardPeriod.today,
      title: 'Dashboard Chuỗi',
      subtitle: 'Doanh thu & hiệu suất thời gian thực',
      metrics: const <DashboardMetricModel>[
        DashboardMetricModel(
          title: 'Doanh thu',
          value: '142,5M',
          change: '▲ 8.3%',
          changeLabel: 'so với hôm qua',
          icon: Icons.payments_rounded,
          color: AppColors.success,
        ),
        DashboardMetricModel(
          title: 'Hóa đơn',
          value: '1,248',
          change: '▲ 5.1%',
          changeLabel: 'tăng tốc',
          icon: Icons.receipt_long_rounded,
          color: AppColors.info,
        ),
        DashboardMetricModel(
          title: 'Lợi nhuận',
          value: '38,2M',
          change: '▲ 2.7%',
          changeLabel: 'biên lợi nhuận',
          icon: Icons.trending_up_rounded,
          color: AppColors.warning,
        ),
        DashboardMetricModel(
          title: 'Chi nhánh',
          value: '12/12',
          change: '● 100% hoạt động',
          changeLabel: '',
          icon: Icons.storefront_rounded,
          color: AppColors.pharmaGreen,
        ),
      ],
      topBranches: const <TopBranchModel>[
        TopBranchModel(name: 'CN Quận 1', city: 'HCM', revenue: '42,1M'),
        TopBranchModel(name: 'CN Hoàn Kiếm', city: 'HN', revenue: '38,7M'),
        TopBranchModel(name: 'CN Hải Châu', city: 'ĐN', revenue: '21,3M'),
      ],
      lastUpdated: DateTime.now(),
    );
  }

  DashboardSummaryModel _weekSummary() {
    return DashboardSummaryModel(
      period: DashboardPeriod.week,
      title: 'Dashboard Chuỗi',
      subtitle: 'Doanh thu & hiệu suất thời gian thực',
      metrics: const <DashboardMetricModel>[
        DashboardMetricModel(
          title: 'Doanh thu',
          value: '863,2M',
          change: '▲ 12.4%',
          changeLabel: 'so với tuần trước',
          icon: Icons.payments_rounded,
          color: AppColors.success,
        ),
        DashboardMetricModel(
          title: 'Hóa đơn',
          value: '7,946',
          change: '▲ 6.8%',
          changeLabel: '',
          icon: Icons.receipt_long_rounded,
          color: AppColors.info,
        ),
        DashboardMetricModel(
          title: 'Lợi nhuận',
          value: '214,8M',
          change: '▲ 4.5%',
          changeLabel: '',
          icon: Icons.trending_up_rounded,
          color: AppColors.warning,
        ),
        DashboardMetricModel(
          title: 'Chi nhánh',
          value: '12/12',
          change: '● Hoạt động',
          changeLabel: '',
          icon: Icons.storefront_rounded,
          color: AppColors.pharmaGreen,
        ),
      ],
      topBranches: const <TopBranchModel>[
        TopBranchModel(name: 'CN Quận 1', city: 'HCM', revenue: '256,4M'),
        TopBranchModel(name: 'CN Hoàn Kiếm', city: 'HN', revenue: '228,5M'),
        TopBranchModel(name: 'CN Hải Châu', city: 'ĐN', revenue: '119,7M'),
      ],
      lastUpdated: DateTime.now(),
    );
  }

  DashboardSummaryModel _monthSummary() {
    return DashboardSummaryModel(
      period: DashboardPeriod.month,
      title: 'Dashboard Chuỗi',
      subtitle: 'Doanh thu & hiệu suất thời gian thực',
      metrics: const <DashboardMetricModel>[
        DashboardMetricModel(
          title: 'Doanh thu',
          value: '3,96B',
          change: '▲ 18.9%',
          changeLabel: 'so với tháng trước',
          icon: Icons.payments_rounded,
          color: AppColors.success,
        ),
        DashboardMetricModel(
          title: 'Hóa đơn',
          value: '32,104',
          change: '▲ 10.2%',
          changeLabel: '',
          icon: Icons.receipt_long_rounded,
          color: AppColors.info,
        ),
        DashboardMetricModel(
          title: 'Lợi nhuận',
          value: '1,02B',
          change: '▲ 7.6%',
          changeLabel: '',
          icon: Icons.trending_up_rounded,
          color: AppColors.warning,
        ),
        DashboardMetricModel(
          title: 'Chi nhánh',
          value: '12/12',
          change: '● Hoạt động',
          changeLabel: '',
          icon: Icons.storefront_rounded,
          color: AppColors.pharmaGreen,
        ),
      ],
      topBranches: const <TopBranchModel>[
        TopBranchModel(name: 'CN Quận 1', city: 'HCM', revenue: '1,02B'),
        TopBranchModel(name: 'CN Hoàn Kiếm', city: 'HN', revenue: '914,3M'),
        TopBranchModel(name: 'CN Hải Châu', city: 'ĐN', revenue: '481,9M'),
      ],
      lastUpdated: DateTime.now(),
    );
  }
}
