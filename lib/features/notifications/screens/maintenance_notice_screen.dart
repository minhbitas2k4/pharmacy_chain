import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/loading_view.dart';
import '../controllers/notification_controller.dart';
import '../widgets/recipient_group_chip.dart';

class MaintenanceNoticeScreen extends StatefulWidget {
  const MaintenanceNoticeScreen({super.key});

  @override
  State<MaintenanceNoticeScreen> createState() =>
      _MaintenanceNoticeScreenState();
}

class _MaintenanceNoticeScreenState extends State<MaintenanceNoticeScreen> {
  late final NotificationController _controller;
  static const List<String> _recipients = <String>[
    'Tất cả',
    'Admin',
    'Manager',
    'Nhân viên',
  ];

  @override
  void initState() {
    super.initState();
    _controller = NotificationController();
    _controller.loadDefaultNotice();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String? validation = _controller.validate();
    if (validation != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validation)));
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Xác nhận gửi thông báo'),
        content: const Text(
          'Bạn có chắc chắn muốn gửi thông báo bảo trì toàn hệ thống?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final bool sent = await _controller.sendNotice();
    if (!mounted || !sent) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã gửi thông báo bảo trì')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Column(
              children: <Widget>[
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Thông báo bảo trì',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Gửi Push Notification toàn hệ thống',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: LoadingView(
                              message: 'Đang tải mẫu thông báo...',
                            ),
                          )
                        else ...<Widget>[
                          TextFormField(
                            controller: _controller.titleController,
                            decoration: const InputDecoration(
                              labelText: 'Tiêu đề thông báo',
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _controller.contentController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Nội dung',
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _controller.timeController,
                            decoration: const InputDecoration(
                              labelText: 'Thời gian bảo trì',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nhóm người nhận',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _recipients
                                .map(
                                  (String recipient) => RecipientGroupChip(
                                    label: recipient,
                                    selected:
                                        _controller.selectedRecipient ==
                                        recipient,
                                    onSelected: () =>
                                        _controller.selectRecipient(recipient),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            text: 'Gửi thông báo',
                            isLoading: _controller.isSending,
                            onPressed: _send,
                          ),
                        ],
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
