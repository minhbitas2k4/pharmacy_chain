enum StockVerificationStatus { enough, shortage, notScanned }

class StockVerificationModel {
  const StockVerificationModel({
    required this.inventoryId,
    required this.name,
    required this.status,
    required this.description,
    this.expectedQuantity,
    this.actualQuantity,
  });

  final String inventoryId;
  final String name;
  final StockVerificationStatus status;
  final String description;
  final int? expectedQuantity;
  final int? actualQuantity;

  factory StockVerificationModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return StockVerificationModel(
      inventoryId: id ?? data['inventory_id'] as String? ?? '',
      name: data['product_name'] as String? ?? '',
      status: StockVerificationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => StockVerificationStatus.notScanned,
      ),
      description: data['description'] as String? ?? '',
      expectedQuantity: data['expected_quantity'] as int?,
      actualQuantity: data['actual_quantity'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_name': name,
      'status': status.name,
      'description': description,
      'expected_quantity': expectedQuantity,
      'actual_quantity': actualQuantity,
    };
  }
}
