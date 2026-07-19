import 'package:flutter/material.dart';

class SupplierModel {
  const SupplierModel({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.status,
    required this.contact,
    required this.lastTransaction,
    required this.address,
  });

  final String name;
  final double rating;
  final int reviews;
  final String status;
  final String contact;
  final String lastTransaction;
  final String address;

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  Color get statusColor =>
      isActive ? const Color(0xFF1B8F3E) : const Color(0xFFC63D3D);
}
