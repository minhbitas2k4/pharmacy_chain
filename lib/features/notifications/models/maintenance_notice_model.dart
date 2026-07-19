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

  factory MaintenanceNoticeModel.fromMap(Map<String, dynamic> data) {
    return MaintenanceNoticeModel(
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      timeRange: data['timeRange'] as String? ?? '',
      recipients: List<String>.from(data['recipients'] as List? ?? <String>[]),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'content': content,
      'timeRange': timeRange,
      'recipients': recipients,
    };
  }
}
