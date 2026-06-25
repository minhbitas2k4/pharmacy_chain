class WarehouseAlertModel {
  const WarehouseAlertModel({
    required this.productName,
    required this.batchCode,
    required this.quantityLabel,
    required this.branchesLabel,
    required this.badgeLabel,
  });

  final String productName;
  final String batchCode;
  final String quantityLabel;
  final String branchesLabel;
  final String badgeLabel;
}
