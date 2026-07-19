import 'package:flutter/material.dart';

enum PricingPolicyStatus { pending, scheduled, active, rejected }

extension PricingPolicyStatusX on PricingPolicyStatus {
  String get label {
    switch (this) {
      case PricingPolicyStatus.pending:
        return 'Chờ duyệt';
      case PricingPolicyStatus.scheduled:
        return 'Lên lịch';
      case PricingPolicyStatus.active:
        return 'Đang áp dụng';
      case PricingPolicyStatus.rejected:
        return 'Từ chối';
    }
  }

  Color get color {
    switch (this) {
      case PricingPolicyStatus.pending:
        return const Color(0xFFE09B1C);
      case PricingPolicyStatus.scheduled:
        return const Color(0xFF2D7FF9);
      case PricingPolicyStatus.active:
        return const Color(0xFF1B8F3E);
      case PricingPolicyStatus.rejected:
        return const Color(0xFFC63D3D);
    }
  }
}

class PricingPolicyModel {
  const PricingPolicyModel({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.storeCount,
  });

  final String title;
  final String subtitle;
  final PricingPolicyStatus status;
  final String storeCount;

  PricingPolicyModel copyWith({PricingPolicyStatus? status}) {
    return PricingPolicyModel(
      title: title,
      subtitle: subtitle,
      status: status ?? this.status,
      storeCount: storeCount,
    );
  }
}
