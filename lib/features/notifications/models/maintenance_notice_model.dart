class MaintenanceNoticeModel {
  const MaintenanceNoticeModel({
    required this.title,
    required this.content,
    required this.timeRange,
    required this.recipients,
  });

  final String title;
  final String content;
  final String timeRange;
  final List<String> recipients;
}
