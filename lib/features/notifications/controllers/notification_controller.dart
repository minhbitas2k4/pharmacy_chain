import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/maintenance_notice_model.dart';
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

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String get selectedRecipient => _selectedRecipient;
  MaintenanceNoticeModel? get notice => _notice;

  Future<void> loadDefaultNotice() async {
    _setLoading(true);
    try {
      _notice = await _notificationService.fetchDefaultNotice();
      titleController.text = _notice!.title;
      contentController.text = _notice!.content;
      timeController.text = _notice!.timeRange;
      _selectedRecipient = _notice!.recipients.first;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
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
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _isSending = false;
    notifyListeners();
    return true;
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
