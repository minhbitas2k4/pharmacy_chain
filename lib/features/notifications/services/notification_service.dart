import '../models/maintenance_notice_model.dart';

class NotificationService {
  Future<MaintenanceNoticeModel> fetchDefaultNotice() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    return const MaintenanceNoticeModel(
      title: 'Bảo trì hệ thống',
      content: 'Hệ thống sẽ bảo trì lúc 23:00 hôm nay...',
      timeRange: '23:00 - 01:00 (12/07/2025)',
      recipients: <String>['Tất cả'],
    );
  }
}
