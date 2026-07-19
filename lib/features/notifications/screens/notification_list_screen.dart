import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/notification_controller.dart';
import '../models/app_notification_model.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationController();
    _controller.loadNotifications();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final String hour = dateTime.hour.toString().padLeft(2, '0');
      final String minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (_) {
      return isoString;
    }
  }

  Widget _buildNotificationItem(AppNotificationModel notif) {
    final isUnread = notif.isRead == 'false';
    final isMaintenance = notif.type == 'maintenance';
    
    IconData iconData = Icons.notifications_rounded;
    Color iconColor = AppColors.pharmaGreen;
    Color iconBg = AppColors.pharmaMint;

    if (isMaintenance) {
      iconData = Icons.build_rounded;
      iconColor = AppColors.info;
      iconBg = AppColors.info.withOpacity(0.12);
    } else if (notif.type == 'expiry_alert') {
      iconData = Icons.warning_amber_rounded;
      iconColor = AppColors.warning;
      iconBg = AppColors.warning.withOpacity(0.12);
    }

    return InkWell(
      onTap: () {
        if (isUnread) {
          _controller.markAsRead(notif.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.pharmaMint.withOpacity(0.08) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.pharmaGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.content,
                    style: TextStyle(
                      color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notif.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final notifs = _controller.notifications;

            return Column(
              children: <Widget>[
                const AppHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _controller.loadNotifications,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Thông báo',
                                style: Theme.of(context).textTheme.headlineMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _controller.isLoading
                              ? const LoadingView(message: 'Đang tải thông báo...')
                              : notifs.isEmpty
                                  ? const EmptyView(
                                      title: 'Không có thông báo',
                                      message: 'Hệ thống chưa ghi nhận thông báo nào cho bạn.',
                                    )
                                  : ListView.builder(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: notifs.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return _buildNotificationItem(notifs[index]);
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
