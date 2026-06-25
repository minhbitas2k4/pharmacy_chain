enum InventoryRequestType { inbound, transfer }

enum InventoryRequestStatus { pending, approved, rejected }

class InventoryRequestModel {
  const InventoryRequestModel({
    required this.code,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.itemsLabel,
    required this.totalLabel,
    required this.status,
  });

  final String code;
  final InventoryRequestType type;
  final String title;
  final String subtitle;
  final String date;
  final String itemsLabel;
  final String totalLabel;
  final InventoryRequestStatus status;

  InventoryRequestModel copyWith({InventoryRequestStatus? status}) {
    return InventoryRequestModel(
      code: code,
      type: type,
      title: title,
      subtitle: subtitle,
      date: date,
      itemsLabel: itemsLabel,
      totalLabel: totalLabel,
      status: status ?? this.status,
    );
  }
}
