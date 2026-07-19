class AttendanceModel {
  const AttendanceModel({
    required this.scheduleId,
    required this.userId,
    required this.workDate,
    required this.status,
    this.userName,
    this.shiftName,
    this.shiftStartTime,
    this.shiftEndTime,
    this.checkInTime,
    this.checkOutTime,
  });

  final String scheduleId;
  final String userId;
  final String workDate;
  final String status; // 'present', 'absent', 'late', 'active', 'handed_over'
  final String? userName;
  final String? shiftName;
  final String? shiftStartTime;
  final String? shiftEndTime;
  final String? checkInTime;
  final String? checkOutTime;

  /// Calculate attendance display status from raw schedule status and check-in data.
  String get attendanceStatus {
    if (checkInTime == null && checkOutTime == null) {
      // Not checked in yet — might be absent or pending
      if (status == 'active') return 'Chưa chấm công';
      if (status == 'absent') return 'Vắng mặt';
    }
    if (checkInTime != null && checkOutTime == null) {
      return 'Đang làm';
    }
    if (checkInTime != null && checkOutTime != null) {
      // Check if late
      if (shiftStartTime != null && checkInTime != null) {
        final shiftParts = shiftStartTime!.split(':');
        final checkParts = checkInTime!.split('T');
        if (checkParts.length > 1) {
          final timeParts = checkParts[1].split(':');
          if (shiftParts.length >= 2 && timeParts.length >= 2) {
            final shiftMinutes =
                int.parse(shiftParts[0]) * 60 + int.parse(shiftParts[1]);
            final checkMinutes =
                int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
            if (checkMinutes > shiftMinutes + 15) {
              return 'Đi trễ';
            }
          }
        }
      }
      return 'Đã hoàn thành';
    }
    return 'Chưa xác định';
  }

  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;
  bool get isAbsent => status == 'absent';

  factory AttendanceModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return AttendanceModel(
      scheduleId: id ?? data['schedule_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      workDate: data['work_date'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      userName: data['user_name'] as String?,
      shiftName: data['shift_name'] as String?,
      shiftStartTime: data['shift_start_time'] as String?,
      shiftEndTime: data['shift_end_time'] as String?,
      checkInTime: data['check_in_time'] as String?,
      checkOutTime: data['check_out_time'] as String?,
    );
  }
}
