class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.senderId,
    required this.targetId,
    required this.createdAt,
    required this.isRead, // "true" or "false" string
  });

  final String id;
  final String title;
  final String content;
  final String type;
  final String senderId;
  final String targetId;
  final String createdAt;
  final String isRead;

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    String? senderId,
    String? targetId,
    String? createdAt,
    String? isRead,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      targetId: targetId ?? this.targetId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'sender_id': senderId,
      'target_id': targetId,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }

  factory AppNotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return AppNotificationModel(
      id: id,
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      type: map['type']?.toString() ?? 'maintenance',
      senderId: map['sender_id']?.toString() ?? 'system',
      targetId: map['target_id']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
      isRead: map['is_read']?.toString() ?? 'false',
    );
  }
}
