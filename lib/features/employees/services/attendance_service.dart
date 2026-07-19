import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream attendance data for a specific date in a branch.
  /// Pulls from schedules collection and enriches with user/shift data.
  Stream<List<AttendanceModel>> getAttendance(
      String branchId, String workDate) {
    return _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .where('work_date', isEqualTo: workDate)
        .snapshots()
        .asyncMap((snapshot) async {
      final records = <AttendanceModel>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['user_id'] as String? ?? '';
        final shiftId = data['shift_id'] as String? ?? '';

        // Get user name
        String? userName;
        if (userId.isNotEmpty) {
          final userDoc = await _db.collection('users').doc(userId).get();
          userName = userDoc.data()?['displayName'] as String?;
        }

        // Get shift info
        String? shiftName;
        String? shiftStartTime;
        String? shiftEndTime;
        if (shiftId.isNotEmpty) {
          final shiftDoc = await _db.collection('shifts').doc(shiftId).get();
          if (shiftDoc.exists) {
            final shiftData = shiftDoc.data()!;
            shiftName = shiftData['name'] as String?;
            shiftStartTime = shiftData['start_time'] as String?;
            shiftEndTime = shiftData['end_time'] as String?;
          }
        }

        records.add(AttendanceModel.fromMap({
          ...data,
          'user_name': userName,
          'shift_name': shiftName,
          'shift_start_time': shiftStartTime,
          'shift_end_time': shiftEndTime,
        }, id: doc.id));
      }

      return records;
    });
  }

  /// Stream monthly attendance data for a branch.
  Stream<List<AttendanceModel>> getMonthlyAttendance(
      String branchId, String month) {
    return _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .where('work_date', isGreaterThanOrEqualTo: '$month-01')
        .where('work_date', isLessThan: '$month-32')
        .snapshots()
        .asyncMap((snapshot) async {
      final records = <AttendanceModel>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['user_id'] as String? ?? '';
        final shiftId = data['shift_id'] as String? ?? '';

        String? userName;
        if (userId.isNotEmpty) {
          final userDoc = await _db.collection('users').doc(userId).get();
          userName = userDoc.data()?['displayName'] as String?;
        }

        String? shiftName;
        String? shiftStartTime;
        String? shiftEndTime;
        if (shiftId.isNotEmpty) {
          final shiftDoc = await _db.collection('shifts').doc(shiftId).get();
          if (shiftDoc.exists) {
            final shiftData = shiftDoc.data()!;
            shiftName = shiftData['name'] as String?;
            shiftStartTime = shiftData['start_time'] as String?;
            shiftEndTime = shiftData['end_time'] as String?;
          }
        }

        records.add(AttendanceModel.fromMap({
          ...data,
          'user_name': userName,
          'shift_name': shiftName,
          'shift_start_time': shiftStartTime,
          'shift_end_time': shiftEndTime,
        }, id: doc.id));
      }

      return records;
    });
  }

  /// Check in: record the current time as check_in_time.
  Future<void> checkIn(String scheduleId) async {
    final now = DateTime.now().toIso8601String();
    await _db.collection('schedules').doc(scheduleId).update({
      'check_in_time': now,
    });
  }

  /// Check out: record the current time as check_out_time.
  Future<void> checkOut(String scheduleId) async {
    final now = DateTime.now().toIso8601String();
    await _db.collection('schedules').doc(scheduleId).update({
      'check_out_time': now,
    });
  }

  /// Mark absent: set schedule status to 'absent'.
  Future<void> markAbsent(String scheduleId) async {
    await _db.collection('schedules').doc(scheduleId).update({
      'status': 'absent',
    });
  }
}
