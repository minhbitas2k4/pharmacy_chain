enum ShiftRequestType { changeShift, leave }

enum ShiftRequestStatus { pending, approved, rejected }

class ShiftRequestModel {
  const ShiftRequestModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    this.userId,
    this.branchId,
    this.workDate,
  });

  final String id;
  final String name;
  final String description;
  final ShiftRequestType type;
  final ShiftRequestStatus status;
  final String? userId;
  final String? branchId;
  final String? workDate;

  factory ShiftRequestModel.fromMap(Map<String, dynamic> data, {String? id}) {
    final String statusStr = data['status'] as String? ?? 'pending';
    final ShiftRequestStatus reqStatus;
    if (statusStr == 'pending_change') {
      reqStatus = ShiftRequestStatus.pending;
    } else if (statusStr == 'pending_leave') {
      reqStatus = ShiftRequestStatus.pending;
    } else {
      reqStatus = ShiftRequestStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => ShiftRequestStatus.pending,
      );
    }

    final String? notes = data['notes'] as String?;
    final String typeStr = notes?.contains('change') == true
        ? 'changeShift'
        : 'leave';

    return ShiftRequestModel(
      id: id ?? data['id'] as String? ?? '',
      name: data['user_id'] as String? ?? '',
      description: notes ?? '',
      type: ShiftRequestType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => ShiftRequestType.leave,
      ),
      status: reqStatus,
      userId: data['user_id'] as String?,
      branchId: data['branch_id'] as String?,
      workDate: data['work_date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'notes': description,
      'branch_id': branchId,
      'work_date': workDate,
      'shift_name': type == ShiftRequestType.changeShift ? 'change' : 'leave',
      'status': status == ShiftRequestStatus.pending
          ? (type == ShiftRequestType.changeShift ? 'pending_change' : 'pending_leave')
          : status.name,
    };
  }

  ShiftRequestModel copyWith({ShiftRequestStatus? status}) {
    return ShiftRequestModel(
      id: id,
      name: name,
      description: description,
      type: type,
      status: status ?? this.status,
      userId: userId,
      branchId: branchId,
      workDate: workDate,
    );
  }
}
