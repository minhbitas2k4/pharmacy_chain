import 'package:flutter/material.dart';

class PurchaseOrderStatusModel {
  const PurchaseOrderStatusModel({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class PurchaseOrderSummaryModel {
  const PurchaseOrderSummaryModel({
    required this.title,
    required this.subtitle,
    required this.statusCards,
    this.isEmpty = false,
  });

  final String title;
  final String subtitle;
  final List<PurchaseOrderStatusModel> statusCards;
  final bool isEmpty;

  factory PurchaseOrderSummaryModel.empty() {
    return const PurchaseOrderSummaryModel(
      title: 'Quản lý Nhập hàng',
      subtitle: 'Theo dõi và xét duyệt đơn yêu cầu mua hàng',
      statusCards: <PurchaseOrderStatusModel>[],
      isEmpty: true,
    );
  }
}
