import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/app_user_model.dart';
import 'role_chip.dart';

class UserPermissionCard extends StatelessWidget {
  const UserPermissionCard({
    super.key,
    required this.user,
    required this.onEditRole,
    required this.onToggleLock,
  });

  final AppUserModel user;
  final VoidCallback onEditRole;
  final VoidCallback onToggleLock;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.pharmaMint,
                child: Text(
                  user.name.substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.pharmaGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.username,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: user.statusLabel,
                backgroundColor: user.statusColor.withValues(alpha: 0.12),
                foregroundColor: user.statusColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          RoleChip(label: user.role),
          const SizedBox(height: 8),
          Text(
            'Thiết bị: ${user.lastSeenDevice} • Hoạt động: ${user.lastActiveAt}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onEditRole,
                  child: const Text('Sửa quyền'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onToggleLock,
                  child: Text(user.isLocked ? 'Mở khóa' : 'Khóa'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
