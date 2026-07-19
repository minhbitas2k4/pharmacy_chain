import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_request_model.dart';
import '../models/stock_verification_model.dart';
import '../models/warehouse_alert_model.dart';

class InventoryService {
  InventoryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<WarehouseAlertModel>> fetchWarehouseAlerts() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('warehouse_alerts')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
      return WarehouseAlertModel(
        productName: data['productName']?.toString() ?? '',
        batchCode: data['batchCode']?.toString() ?? '',
        quantityLabel: data['quantityLabel']?.toString() ?? '',
        branchesLabel: data['branchesLabel']?.toString() ?? '',
        badgeLabel: data['badgeLabel']?.toString() ?? '',
      );
    }).toList();
  }

  Future<List<InventoryRequestModel>> fetchReviewRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const <InventoryRequestModel>[
      InventoryRequestModel(
        code: 'PO-2025-0741',
        type: InventoryRequestType.inbound,
        title: 'Nhập hàng',
        subtitle: 'Purchasing Mgr: Phạm Hùng',
        date: '10/07/2025',
        itemsLabel: 'Kháng sinh nhóm Beta-lactam x 12 SKU',
        totalLabel: '8.400.000đ',
        status: InventoryRequestStatus.pending,
      ),
      InventoryRequestModel(
        code: 'TK-2025-0188',
        type: InventoryRequestType.transfer,
        title: 'Chuyển kho',
        subtitle: 'Từ CN Bình Thạnh → Quận 1',
        date: '11/07/2025',
        itemsLabel: 'Paracetamol 500mg x 200 hộp',
        totalLabel: '',
        status: InventoryRequestStatus.pending,
      ),
    ];
  }

  Future<List<StockVerificationModel>> fetchStockVerification() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const <StockVerificationModel>[
      StockVerificationModel(
        name: 'Amoxicillin 500mg',
        status: StockVerificationStatus.enough,
        description: 'Đủ',
      ),
      StockVerificationModel(
        name: 'Augmentin 1g',
        status: StockVerificationStatus.shortage,
        description: 'Thiếu 2 hộp',
      ),
      StockVerificationModel(
        name: 'Cephalexin 500mg',
        status: StockVerificationStatus.notScanned,
        description: 'Chưa quét',
      ),
    ];
  }
}
