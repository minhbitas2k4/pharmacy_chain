import 'package:flutter/material.dart';

enum AuditFilter { all, login, config, inventory, price }

extension AuditFilterX on AuditFilter {
  String get label {
    switch (this) {
      case AuditFilter.all:
        return 'Tất cả';
      case AuditFilter.login:
        return 'Đăng nhập';
      case AuditFilter.config:
        return 'Cấu hình';
      case AuditFilter.inventory:
        return 'Kho';
      case AuditFilter.price:
        return 'Giá';
    }
  }
}

class AuditLogModel {
  const AuditLogModel({
    required this.actionType,
    required this.actor,
    required this.time,
    required this.description,
    required this.status,
    required this.filter,
    this.device = 'Android App',
    this.location = 'Hà Nội',
  });

  final String actionType;
  final String actor;
  final String time;
  final String description;
  final String status;
  final AuditFilter filter;
  final String device;
  final String location;

  Color get statusColor {
    switch (status) {
      case 'warning':
        return const Color(0xFFE09B1C);
      case 'error':
        return const Color(0xFFC63D3D);
      default:
        return const Color(0xFF1B8F3E);
    }
  }
}
