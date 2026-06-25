import '../models/inventory_request_model.dart';
import '../models/stock_verification_model.dart';
import '../models/warehouse_alert_model.dart';

class InventoryService {
  Future<List<WarehouseAlertModel>> fetchWarehouseAlerts() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const <WarehouseAlertModel>[
      WarehouseAlertModel(
        productName: 'Augmentin 1g',
        batchCode: 'LOT230701',
        quantityLabel: '150 hộp',
        branchesLabel: 'CN Quận 1, CN Bình Thạnh',
        badgeLabel: 'Còn 12 ngày',
      ),
      WarehouseAlertModel(
        productName: 'Insulin Lantus 100UI',
        batchCode: 'LAN240612',
        quantityLabel: '48 bút',
        branchesLabel: 'CN Hoàn Kiếm',
        badgeLabel: 'Còn 8 ngày',
      ),
    ];
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
