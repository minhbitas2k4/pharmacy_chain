class WarehouseAlertModel {
  const WarehouseAlertModel({
    required this.inventoryId,
    required this.productName,
    required this.batchCode,
    required this.quantity,
    required this.expiryDate,
    required this.badgeLabel,
    this.productId,
    this.branchId,
  });

  final String inventoryId;
  final String productName;
  final String batchCode;
  final int quantity;
  final String expiryDate;
  final String badgeLabel;
  final String? productId;
  final String? branchId;

  factory WarehouseAlertModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return WarehouseAlertModel(
      inventoryId: id ?? data['inventory_id'] as String? ?? '',
      productName: data['product_name'] as String? ?? '',
      batchCode: data['batch_number'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 0,
      expiryDate: data['expiry_date'] as String? ?? '',
      badgeLabel: data['badge_label'] as String? ?? '',
      productId: data['product_id'] as String?,
      branchId: data['branch_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'batch_number': batchCode,
      'quantity': quantity,
      'expiry_date': expiryDate,
      'badge_label': badgeLabel,
      'product_id': productId,
      'branch_id': branchId,
    };
  }
}
