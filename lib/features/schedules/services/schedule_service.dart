import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/work_schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<WorkScheduleModel>> getSchedules(String branchId, String month) {
    return _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .where('work_date', isGreaterThanOrEqualTo: '$month-01')
        .where('work_date', isLessThan: '$month-32')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkScheduleModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

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
      'notes': notes,
    });
  }
}
