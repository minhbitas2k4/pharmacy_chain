import 'package:flutter/material.dart';

class AppUserModel {
  const AppUserModel({
    required this.name,
    required this.username,
    required this.role,
    required this.isLocked,
  });

  final String name;
  final String username;
  final String role;
  final bool isLocked;

  AppUserModel copyWith({
    String? name,
    String? username,
    String? role,
    bool? isLocked,
  }) {
    return AppUserModel(
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  String get statusLabel => isLocked ? 'Locked' : 'Active';
  Color get statusColor =>
      isLocked ? const Color(0xFFC63D3D) : const Color(0xFF1B8F3E);
}
