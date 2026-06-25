class ShiftHandoverModel {
  const ShiftHandoverModel({
    required this.currentShift,
    required this.cashier,
    required this.invoiceCount,
    required this.systemCash,
    required this.qrPayment,
    required this.cardPayment,
    required this.totalRevenue,
  });

  final String currentShift;
  final String cashier;
  final int invoiceCount;
  final String systemCash;
  final String qrPayment;
  final String cardPayment;
  final String totalRevenue;
}
