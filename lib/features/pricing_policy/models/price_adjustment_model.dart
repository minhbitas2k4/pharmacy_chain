class PriceAdjustmentModel {
  const PriceAdjustmentModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.branchId,
    required this.branchName,
    required this.oldPrice,
    required this.newPrice,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String productId;
  final String productName;
  final String branchId;
  final String branchName;
  final String oldPrice;
  final String newPrice;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime? createdAt;

  PriceAdjustmentModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? branchId,
    String? branchName,
    String? oldPrice,
    String? newPrice,
    String? reason,
    String? status,
    DateTime? createdAt,
  }) {
    return PriceAdjustmentModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      oldPrice: oldPrice ?? this.oldPrice,
      newPrice: newPrice ?? this.newPrice,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'branch_id': branchId,
      'branch_name': branchName,
      'old_price': oldPrice,
      'new_price': newPrice,
      'reason': reason,
      'status': status,
      'created_at': createdAt != null ? createdAt!.toIso8601String() : null,
    };
  }

  factory PriceAdjustmentModel.fromMap(String id, Map<String, dynamic> map) {
    return PriceAdjustmentModel(
      id: id,
      productId: map['product_id']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      branchId: map['branch_id']?.toString() ?? '',
      branchName: map['branch_name']?.toString() ?? '',
      oldPrice: map['old_price']?.toString() ?? '',
      newPrice: map['new_price']?.toString() ?? '',
      reason: map['reason']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }
}
