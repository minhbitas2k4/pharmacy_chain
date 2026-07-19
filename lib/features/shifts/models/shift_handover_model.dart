class ShiftHandoverModel {
  const ShiftHandoverModel({
    required this.shiftId,
    required this.branchId,
    required this.currentShift,
    required this.cashier,
    required this.cashierId,
    required this.invoiceCount,
    required this.systemCash,
    required this.qrPayment,
    required this.cardPayment,
    required this.totalRevenue,
  });

  final String shiftId;
  final String branchId;
  final String currentShift;
  final String cashier;
  final String cashierId;
  final int invoiceCount;
  final String systemCash;
  final String qrPayment;
  final String cardPayment;
  final String totalRevenue;

  factory ShiftHandoverModel.fromMap(Map<String, dynamic> data) {
    return ShiftHandoverModel(
      shiftId: data['shift_id'] as String? ?? '',
      branchId: data['branch_id'] as String? ?? '',
      currentShift: data['current_shift'] as String? ?? '',
      cashier: data['cashier'] as String? ?? '',
      cashierId: data['cashier_id'] as String? ?? '',
      invoiceCount: data['invoice_count'] as int? ?? 0,
      systemCash: data['system_cash'] as String? ?? '0đ',
      qrPayment: data['qr_payment'] as String? ?? '0đ',
      cardPayment: data['card_payment'] as String? ?? '0đ',
      totalRevenue: data['total_revenue'] as String? ?? '0đ',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shift_id': shiftId,
      'branch_id': branchId,
      'current_shift': currentShift,
      'cashier': cashier,
      'cashier_id': cashierId,
      'invoice_count': invoiceCount,
      'system_cash': systemCash,
      'qr_payment': qrPayment,
      'card_payment': cardPayment,
      'total_revenue': totalRevenue,
    };
  }
}
