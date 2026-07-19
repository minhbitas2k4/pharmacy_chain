import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_request_model.dart';
import '../models/stock_verification_model.dart';
import '../models/warehouse_alert_model.dart';

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<WarehouseAlertModel>> getWarehouseAlerts(String branchId) {
    return _db
        .collection('inventories')
        .where('branch_id', isEqualTo: branchId)
        .snapshots()
        .asyncMap((snapshot) async {
      final alerts = <WarehouseAlertModel>[];
      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final expiryStr = data['expiry_date'] as String? ?? '';
        final quantity = int.tryParse(data['quantity'] as String? ?? '') ?? 0;
        final minStock = int.tryParse(data['min_stock'] as String? ?? '') ?? 10;

        DateTime? expiryDate;
        if (expiryStr.isNotEmpty) {
          expiryDate = DateTime.tryParse(expiryStr);
        }

        bool isExpiringSoon = false;
        if (expiryDate != null && expiryDate.isBefore(thirtyDaysLater)) {
          isExpiringSoon = true;
        }

        bool isLowStock = quantity <= minStock;

        if (isExpiringSoon || isLowStock) {
          final productDoc = await _db
              .collection('products')
              .doc(data['product_id'] as String?)
              .get();

          final productName = productDoc.data()?['product_name'] as String? ?? '';
          final daysLeft = expiryDate != null
              ? expiryDate.difference(now).inDays
              : 999;

          alerts.add(WarehouseAlertModel(
            inventoryId: doc.id,
            productName: productName,
            batchCode: data['batch_number'] as String? ?? '',
            quantity: quantity,
            expiryDate: expiryStr,
            badgeLabel: isExpiringSoon ? 'Còn $daysLeft ngày' : 'Thiếu ${minStock - quantity}',
            productId: data['product_id'] as String?,
            branchId: branchId,
          ));
        }
      }

      alerts.sort((a, b) {
        if (a.badgeLabel.contains('ngày')) return -1;
        return 1;
      });

      return alerts;
    });
  }

  Stream<List<InventoryRequestModel>> getReviewRequests(String branchId) {
    return _db
        .collection('orders')
        .where('branch_id', isEqualTo: branchId)
        .snapshots()
        .map((snapshot) {
      final validStatuses = {'pending', 'approved', 'rejected'};
      return snapshot.docs.where((doc) {
        return validStatuses.contains(doc.data()['status']);
      }).map((doc) {
        final data = doc.data();
        final createdAt = (data['created_at'] as Timestamp?)?.toDate();
        final dateStr = createdAt != null
            ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
            : '';

        return InventoryRequestModel(
          id: doc.id,
          code: 'PO-${doc.id.substring(0, 8).toUpperCase()}',
          type: InventoryRequestType.inbound,
          title: 'Nhập hàng',
          subtitle: 'Từ nhà cung cấp',
          date: dateStr,
          itemsLabel: '${(data['items'] as List?)?.length ?? 0} mặt hàng',
          totalLabel: '${data['total_amount'] ?? 0}đ'.replaceAll('null', '0'),
          status: InventoryRequestStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => InventoryRequestStatus.pending,
          ),
        );
      }).toList();
    });
  }

  Stream<List<StockVerificationModel>> getStockVerification(String branchId) {
    return _db
        .collection('inventories')
        .where('branch_id', isEqualTo: branchId)
        .snapshots()
        .asyncMap((snapshot) async {
      final items = <StockVerificationModel>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final quantity = int.tryParse(data['quantity'] as String? ?? '') ?? 0;
        final minStock = int.tryParse(data['min_stock'] as String? ?? '') ?? 10;

        final productDoc = await _db
            .collection('products')
            .doc(data['product_id'] as String?)
            .get();

        final productName = productDoc.data()?['product_name'] as String? ?? '';

        StockVerificationStatus status;
        String description;

        if (quantity >= minStock) {
          status = StockVerificationStatus.enough;
          description = 'Đủ';
        } else {
          status = StockVerificationStatus.shortage;
          description = 'Thiếu ${minStock - quantity} đơn vị';
        }

        items.add(StockVerificationModel(
          inventoryId: doc.id,
          name: productName,
          status: status,
          description: description,
          expectedQuantity: minStock,
          actualQuantity: quantity,
        ));
      }

      return items;
    });
  }

  Future<void> approveRequest(String requestId) async {
    await _db.collection('orders').doc(requestId).update({
      'status': 'approved',
    });
  }

  Future<void> rejectRequest(String requestId) async {
    await _db.collection('orders').doc(requestId).update({
      'status': 'rejected',
    });
  }
}
