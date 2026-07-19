import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/maintenance_notice_model.dart';
import '../models/app_notification_model.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<MaintenanceNoticeModel> fetchDefaultNotice() async {
    try {
      final doc = await _db.collection('system_configs').doc('maintenance_notice').get();
      if (doc.exists && doc.data() != null) {
        return MaintenanceNoticeModel.fromMap(doc.data()!);
      }
    } catch (_) {
      // fallback to default notice
    }
    return const MaintenanceNoticeModel(
      title: 'Bảo trì hệ thống',
      content: 'Hệ thống sẽ bảo trì lúc 23:00 hôm nay...',
      timeRange: '23:00 - 01:00 (12/07/2025)',
      recipients: <String>['Tất cả'],
    );
  }

  Future<void> sendNotice(MaintenanceNoticeModel notice, {required String senderId}) async {
    // 1. Save the notice as the latest template
    await _db.collection('system_configs').doc('maintenance_notice').set(
      notice.toMap(),
      SetOptions(merge: true),
    );

    // 2. Fetch users to determine recipients
    final usersSnapshot = await _db.collection('users').get();
    final String selectedGroup = notice.recipients.isNotEmpty ? notice.recipients.first : 'Tất cả';

    final targetUsers = usersSnapshot.docs.where((doc) {
      final data = doc.data();
      final role = (data['role'] as String? ?? '').toLowerCase();

      switch (selectedGroup) {
        case 'Admin':
          return role == 'system_admin';
        case 'Manager':
          return role == 'chain_manager' || role == 'branch_manager';
        case 'Nhân viên':
          return role == 'pharmacist' || role == 'cashier' || role == 'warehouse_staff' || role == 'hr_admin';
        case 'Tất cả':
        default:
          return true;
      }
    }).toList();

    // 3. Write individual notification documents
    final batch = _db.batch();
    final createdAt = DateTime.now().toUtc().toIso8601String();

    for (final userDoc in targetUsers) {
      final userId = userDoc.id; // document ID is user's UID
      final newDocRef = _db.collection('notifications').doc();
      batch.set(newDocRef, {
        'title': notice.title,
        'content': '${notice.content}\nThời gian: ${notice.timeRange}',
        'type': 'maintenance',
        'sender_id': senderId,
        'target_id': userId,
        'created_at': createdAt,
        'is_read': 'false',
      });
    }

    await batch.commit();
  }

  Future<List<AppNotificationModel>> fetchNotifications(String targetId) async {
    try {
      final snapshot = await _db
          .collection('notifications')
          .where('target_id', isEqualTo: targetId)
          .orderBy('created_at', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AppNotificationModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (_) {
      // If error or index not built yet, fallback to local collection scan without ordering
      try {
        final snapshot = await _db
            .collection('notifications')
            .where('target_id', isEqualTo: targetId)
            .get();
        final list = snapshot.docs
            .map((doc) => AppNotificationModel.fromMap(doc.id, doc.data()))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      } catch (_) {
        return [];
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'is_read': 'true',
    });
  }

  Future<void> runAutomaticInventoryScan(String targetId) async {
    try {
      final inventoriesSnapshot = await _db.collection('inventories').get();
      final productsSnapshot = await _db.collection('products').get();
      
      final productsMap = {
        for (var doc in productsSnapshot.docs)
          doc.id: doc.data()['product_name']?.toString() ?? doc.id
      };
      
      final existingSnapshot = await _db
          .collection('notifications')
          .where('target_id', isEqualTo: targetId)
          .get();
          
      final existingTitles = existingSnapshot.docs
          .map((doc) => doc.data()['title']?.toString() ?? '')
          .toSet();

      final batch = _db.batch();
      final now = DateTime.now();
      bool hasNewAlerts = false;

      for (final doc in inventoriesSnapshot.docs) {
        final data = doc.data();
        final productId = data['product_id']?.toString() ?? '';
        final productName = productsMap[productId] ?? productId;
        final batchNumber = data['batch_number']?.toString() ?? '';
        
        final qty = int.tryParse(data['quantity']?.toString() ?? '') ?? 0;
        final minStock = int.tryParse(data['min_stock']?.toString() ?? '') ?? 0;
        
        final expiryStr = data['expiry_date']?.toString() ?? '';
        DateTime? expiryDate;
        if (expiryStr.isNotEmpty) {
          expiryDate = DateTime.tryParse(expiryStr);
        }

        // Check low stock
        if (qty <= minStock && qty > 0) {
          final title = 'Sắp hết hàng: $productName (Lô $batchNumber)';
          if (!existingTitles.contains(title)) {
            final newDocRef = _db.collection('notifications').doc();
            batch.set(newDocRef, {
              'title': title,
              'content': 'Sản phẩm $productName chỉ còn tồn kho $qty (mức tối thiểu là $minStock). Vui lòng bổ sung.',
              'type': 'expiry_alert',
              'sender_id': 'system',
              'target_id': targetId,
              'created_at': DateTime.now().toUtc().toIso8601String(),
              'is_read': 'false',
            });
            hasNewAlerts = true;
          }
        } else if (qty == 0) {
          final title = 'Hết hàng: $productName (Lô $batchNumber)';
          if (!existingTitles.contains(title)) {
            final newDocRef = _db.collection('notifications').doc();
            batch.set(newDocRef, {
              'title': title,
              'content': 'Sản phẩm $productName đã hết hàng hoàn toàn trong kho.',
              'type': 'expiry_alert',
              'sender_id': 'system',
              'target_id': targetId,
              'created_at': DateTime.now().toUtc().toIso8601String(),
              'is_read': 'false',
            });
            hasNewAlerts = true;
          }
        }

        // Check near expiry (less than 30 days)
        if (expiryDate != null) {
          final diffDays = expiryDate.difference(now).inDays;
          if (diffDays <= 30 && diffDays >= 0) {
            final title = 'Sắp hết hạn: $productName (Lô $batchNumber)';
            if (!existingTitles.contains(title)) {
              final newDocRef = _db.collection('notifications').doc();
              batch.set(newDocRef, {
                'title': title,
                'content': 'Lô thuốc $batchNumber của $productName sẽ hết hạn vào ngày $expiryStr (còn $diffDays ngày).',
                'type': 'expiry_alert',
                'sender_id': 'system',
                'target_id': targetId,
                'created_at': DateTime.now().toUtc().toIso8601String(),
                'is_read': 'false',
              });
              hasNewAlerts = true;
            }
          }
        }
      }

      if (hasNewAlerts) {
        await batch.commit();
      }
    } catch (_) {}
  }
}
