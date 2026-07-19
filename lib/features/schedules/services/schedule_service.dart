import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/work_schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream schedules for a branch in a given month (YYYY-MM).
  /// Enriches each schedule with user displayName and shift name.
  Stream<List<WorkScheduleModel>> getSchedules(String branchId, String month) {
    return _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .where('work_date', isGreaterThanOrEqualTo: '$month-01')
        .where('work_date', isLessThan: '$month-32')
        .snapshots()
        .asyncMap((snapshot) async {
      final schedules = <WorkScheduleModel>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['user_id'] as String? ?? '';
        final shiftId = data['shift_id'] as String? ?? '';

        // Enrich: get user name
        String? userName;
        if (userId.isNotEmpty) {
          final userDoc = await _db.collection('users').doc(userId).get();
          userName = userDoc.data()?['displayName'] as String?;
        }

        // Enrich: get shift name
        String? shiftName;
        if (shiftId.isNotEmpty) {
          final shiftDoc = await _db.collection('shifts').doc(shiftId).get();
          shiftName = shiftDoc.data()?['name'] as String?;
        }

        schedules.add(WorkScheduleModel.fromMap(
          {...data, 'user_name': userName, 'shift_name': shiftName},
          id: doc.id,
        ));
      }

      return schedules;
    });
  }

  /// Stream schedules for a specific user in a branch.
  Stream<List<WorkScheduleModel>> getSchedulesByUser(
      String branchId, String userId, String month) {
    return _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .where('user_id', isEqualTo: userId)
        .where('work_date', isGreaterThanOrEqualTo: '$month-01')
        .where('work_date', isLessThan: '$month-32')
        .snapshots()
        .asyncMap((snapshot) async {
      final schedules = <WorkScheduleModel>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final shiftId = data['shift_id'] as String? ?? '';

        String? shiftName;
        if (shiftId.isNotEmpty) {
          final shiftDoc = await _db.collection('shifts').doc(shiftId).get();
          shiftName = shiftDoc.data()?['name'] as String?;
        }

        final userDoc = await _db.collection('users').doc(userId).get();
        final userName = userDoc.data()?['displayName'] as String?;

        schedules.add(WorkScheduleModel.fromMap(
          {...data, 'user_name': userName, 'shift_name': shiftName},
          id: doc.id,
        ));
      }

      return schedules;
    });
  }

  /// Add a new schedule.
  Future<void> addSchedule({
    required String branchId,
    required String userId,
    required String shiftId,
    required String workDate,
    String? notes,
  }) async {
    await _db.collection('schedules').add({
      'branch_id': branchId,
      'user_id': userId,
      'shift_id': shiftId,
      'work_date': workDate,
      'status': 'active',
      'notes': notes ?? '',
    });
  }

  /// Update an existing schedule.
  Future<void> updateSchedule(
      String scheduleId, Map<String, dynamic> data) async {
    await _db.collection('schedules').doc(scheduleId).update(data);
  }

  /// Delete a schedule.
  Future<void> deleteSchedule(String scheduleId) async {
    await _db.collection('schedules').doc(scheduleId).delete();
  }

  /// Get all shifts for a branch (for dropdowns).
  Future<List<Map<String, dynamic>>> getShifts(String branchId) async {
    final snapshot = await _db
        .collection('shifts')
        .where('branch_id', isEqualTo: branchId)
        .get();
    return snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  /// Get all employees for a branch (for dropdowns).
  Future<List<Map<String, dynamic>>> getBranchEmployees(
      String branchId) async {
    final snapshot = await _db
        .collection('users')
        .where('branchId', isEqualTo: branchId)
        .get();
    return snapshot.docs.map((doc) {
      return {'uid': doc.id, ...doc.data()};
    }).toList();
  }
}
