enum ShiftRequestType { changeShift, leave }

enum ShiftRequestStatus { pending, approved, rejected }

class ShiftRequestModel {
  const ShiftRequestModel({
    required this.name,
    required this.description,
    required this.type,
    required this.status,
  });

  final String name;
  final String description;
  final ShiftRequestType type;
  final ShiftRequestStatus status;

  ShiftRequestModel copyWith({ShiftRequestStatus? status}) {
    return ShiftRequestModel(
      name: name,
      description: description,
      type: type,
      status: status ?? this.status,
    );
  }
}
