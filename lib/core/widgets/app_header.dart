import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.onNotificationsPressed,
    this.onProfilePressed,
  });

  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: onProfilePressed,
            child: const Icon(
              Icons.person_outline,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppStrings.appName,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onNotificationsPressed,
          icon: const Icon(Icons.notifications_none_outlined),
        ),
      ],
    );
  }
}
