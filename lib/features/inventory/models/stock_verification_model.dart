enum StockVerificationStatus { enough, shortage, notScanned }

class StockVerificationModel {
  const StockVerificationModel({
    required this.name,
    required this.status,
    required this.description,
  });

  final String name;
  final StockVerificationStatus status;
  final String description;
}
