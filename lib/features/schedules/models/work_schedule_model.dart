class WorkScheduleModel {
  const WorkScheduleModel({
    required this.scheduleId,
    required this.userId,
    required this.shiftId,
    required this.branchId,
    required this.workDate,
    required this.status,
    this.notes,
    this.shiftName,
    this.userName,
  });

  final String scheduleId;
  final String userId;
  final String shiftId;
  final String branchId;
  final String workDate;
  final String status;
  final String? notes;
  final String? shiftName;
  final String? userName;

  factory WorkScheduleModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return WorkScheduleModel(
      scheduleId: id ?? data['schedule_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      shiftId: data['shift_id'] as String? ?? data['shift_name'] as String? ?? '',
      branchId: data['branch_id'] as String? ?? '',
      workDate: data['work_date'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      notes: data['notes'] as String?,
      shiftName: data['shift_name'] as String?,
      userName: data['user_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'shift_id': shiftId,
      'branch_id': branchId,
      'work_date': workDate,
      'status': status,
      'notes': notes,
      'shift_name': shiftName,
      'user_name': userName,
    };
  }
}
