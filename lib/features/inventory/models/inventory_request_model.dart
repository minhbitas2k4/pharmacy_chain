enum InventoryRequestType { inbound, transfer }

enum InventoryRequestStatus { pending, approved, rejected }

class InventoryRequestModel {
  const InventoryRequestModel({
    required this.id,
    required this.code,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.itemsLabel,
    required this.totalLabel,
    required this.status,
  });

  final String id;
  final String code;
  final InventoryRequestType type;
  final String title;
  final String subtitle;
  final String date;
  final String itemsLabel;
  final String totalLabel;
  final InventoryRequestStatus status;

  factory InventoryRequestModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return InventoryRequestModel(
      id: id ?? data['id'] as String? ?? '',
      code: data['code'] as String? ?? '',
      type: InventoryRequestType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => InventoryRequestType.inbound,
      ),
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      date: data['date'] as String? ?? '',
      itemsLabel: data['items_label'] as String? ?? '',
      totalLabel: data['total_label'] as String? ?? '',
      status: InventoryRequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => InventoryRequestStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'date': date,
      'items_label': itemsLabel,
      'total_label': totalLabel,
      'status': status.name,
    };
  }

  InventoryRequestModel copyWith({InventoryRequestStatus? status}) {
    return InventoryRequestModel(
      id: id,
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
