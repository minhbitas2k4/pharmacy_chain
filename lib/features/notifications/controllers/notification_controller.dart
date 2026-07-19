import 'package:flutter/material.dart';

import '../../auth/controllers/auth_controller.dart';
import '../models/maintenance_notice_model.dart';
import '../models/app_notification_model.dart';
import '../services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService() {
    titleController = TextEditingController(text: 'Bảo trì hệ thống');
    contentController = TextEditingController(
      text: 'Hệ thống sẽ bảo trì lúc 23:00 hôm nay...',
    );
    timeController = TextEditingController(text: '23:00 - 01:00 (12/07/2025)');
  }

  final NotificationService _notificationService;
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late final TextEditingController timeController;

  bool _isLoading = false;
  bool _isSending = false;
  String _selectedRecipient = 'Tất cả';
  MaintenanceNoticeModel? _notice;
  List<AppNotificationModel> _notifications = [];

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String get selectedRecipient => _selectedRecipient;
  MaintenanceNoticeModel? get notice => _notice;
  List<AppNotificationModel> get notifications => _notifications;

  Future<void> loadDefaultNotice() async {
    _setLoading(true);
    try {
      _notice = await _notificationService.fetchDefaultNotice();
      titleController.text = _notice!.title;
      contentController.text = _notice!.content;
      timeController.text = _notice!.timeRange;
      _selectedRecipient = _notice!.recipients.isNotEmpty ? _notice!.recipients.first : 'Tất cả';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      final String targetId = AuthController().currentUser?.id ?? 'system';
      await _notificationService.runAutomaticInventoryScan(targetId);
      _notifications = await _notificationService.fetchNotifications(targetId);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      _notifications = _notifications.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: 'true');
        }
        return item;
      }).toList();
      notifyListeners();
    } catch (_) {}
  }

  void selectRecipient(String recipient) {
    _selectedRecipient = recipient;
    notifyListeners();
  }

  String? validate() {
    if (titleController.text.trim().isEmpty) {
      return 'Vui lòng nhập tiêu đề thông báo';
    }
    if (contentController.text.trim().isEmpty) {
      return 'Vui lòng nhập nội dung thông báo';
    }
    if (timeController.text.trim().isEmpty) {
      return 'Vui lòng nhập thời gian bảo trì';
    }
    return null;
  }

  Future<bool> sendNotice() async {
    if (validate() != null) {
      return false;
    }
    _isSending = true;
    notifyListeners();

    try {
      final String senderId = AuthController().currentUser?.id ?? 'system';
      final MaintenanceNoticeModel notice = MaintenanceNoticeModel(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        timeRange: timeController.text.trim(),
        recipients: <String>[_selectedRecipient],
      );

      await _notificationService.sendNotice(notice, senderId: senderId);
      _notice = notice;
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    timeController.dispose();
    super.dispose();
  }
}
