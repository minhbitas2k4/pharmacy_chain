import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/purchase_order_summary_model.dart';

class PurchaseOrderService {
  Future<PurchaseOrderSummaryModel> fetchSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return const PurchaseOrderSummaryModel(
      title: 'Quản lý Nhập hàng',
      subtitle: 'Theo dõi và xét duyệt đơn yêu cầu mua hàng',
      statusCards: <PurchaseOrderStatusModel>[
        PurchaseOrderStatusModel(
          title: 'CHỜ DUYỆT',
          count: '12',
          subtitle: 'Đơn đang đợi xử lý',
          icon: Icons.hourglass_top_rounded,
          color: AppColors.warning,
        ),
        PurchaseOrderStatusModel(
          title: 'ĐANG GIAO',
          count: '08',
          subtitle: 'Đơn đang trên đường',
          icon: Icons.local_shipping_rounded,
          color: AppColors.info,
        ),
        PurchaseOrderStatusModel(
          title: 'HOÀN THÀNH',
          count: '45',
          subtitle: 'Đã nhận đủ hàng',
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
        ),
      ],
    );
  }

  Future<PurchaseOrderSummaryModel> fetchEmptySummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return PurchaseOrderSummaryModel.empty();
  }

  Future<PurchaseOrderSummaryModel> fetchErrorSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    throw Exception('Mock purchase order error');
  }
}
