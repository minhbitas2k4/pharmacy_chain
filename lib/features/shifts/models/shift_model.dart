class ShiftModel {
  const ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.branchId,
    this.status,
  });

  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final String? branchId;
  final String? status;

  factory ShiftModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return ShiftModel(
      id: id ?? data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      startTime: data['start_time'] as String? ?? '',
      endTime: data['end_time'] as String? ?? '',
      branchId: data['branch_id'] as String?,
      status: data['status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'branch_id': branchId,
      'status': status,
    };
  }
}
