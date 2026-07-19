import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/shift_handover_model.dart';
import '../models/shift_model.dart';
import '../models/shift_request_model.dart';

class ShiftService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ShiftModel>> getScheduleByRange({
    required String branchId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final startStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    return _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .snapshots()
        .asyncMap((snapshot) async {
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final workDate = data['work_date'] as String? ?? '';
        return workDate.compareTo(startStr) >= 0 &&
            workDate.compareTo(endStr) <= 0;
      }).toList();

      final shifts = <ShiftModel>[];

      for (final doc in filteredDocs) {
        final data = doc.data();
        final shiftId = data['shift_id'] as String?;
        final workDate = data['work_date'] as String? ?? '';
        final status = data['status'] as String? ?? '';

        String shiftName = '';
        String startTime = '';
        String endTime = '';

        if (shiftId != null && shiftId.isNotEmpty) {
          final shiftDoc = await _db.collection('shifts').doc(shiftId).get();
          if (shiftDoc.exists) {
            final shiftData = shiftDoc.data()!;
            shiftName = shiftData['name'] as String? ?? '';
            startTime = shiftData['start_time'] as String? ?? '';
            endTime = shiftData['end_time'] as String? ?? '';
          }
        }

        final userDoc = await _db
            .collection('users')
            .doc(data['user_id'] as String?)
            .get();

        final userName = userDoc.data()?['displayName'] as String? ?? '';

        shifts.add(ShiftModel(
          id: doc.id,
          name: userName,
          startTime: startTime,
          endTime: endTime,
          branchId: branchId,
          status: status,
          shiftName: shiftName,
          workDate: workDate,
        ));
      }

      shifts.sort((a, b) {
        if (a.workDate != b.workDate) return a.workDate.compareTo(b.workDate);
        return a.startTime.compareTo(b.startTime);
      });

      return shifts;
    });
  }

  Stream<List<ShiftRequestModel>> getChangeRequests(String branchId) {
    return _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .snapshots()
        .asyncMap((snapshot) async {
      final pendingChangeDocs = snapshot.docs.where((doc) {
        return doc.data()['status'] == 'pending_change';
      }).toList();

      final requests = <ShiftRequestModel>[];

      for (final doc in pendingChangeDocs) {
        final data = doc.data();
        final userDoc = await _db
            .collection('users')
            .doc(data['user_id'] as String?)
            .get();

        final userName = userDoc.data()?['displayName'] as String? ?? '';

        requests.add(ShiftRequestModel(
          id: doc.id,
          name: userName,
          description: data['notes'] as String? ?? 'Muốn đổi ca',
          type: ShiftRequestType.changeShift,
          status: ShiftRequestStatus.pending,
          userId: data['user_id'] as String?,
          branchId: branchId,
          workDate: data['work_date'] as String?,
        ));
      }

      return requests;
    });
  }

  Stream<List<ShiftRequestModel>> getLeaveRequests(String branchId) {
    return _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .snapshots()
        .asyncMap((snapshot) async {
      final pendingLeaveDocs = snapshot.docs.where((doc) {
        return doc.data()['status'] == 'pending_leave';
      }).toList();

      final requests = <ShiftRequestModel>[];

      for (final doc in pendingLeaveDocs) {
        final data = doc.data();
        final userDoc = await _db
            .collection('users')
            .doc(data['user_id'] as String?)
            .get();

        final userName = userDoc.data()?['displayName'] as String? ?? '';

        requests.add(ShiftRequestModel(
          id: doc.id,
          name: userName,
          description: data['notes'] as String? ?? 'Xin nghỉ phép',
          type: ShiftRequestType.leave,
          status: ShiftRequestStatus.pending,
          userId: data['user_id'] as String?,
          branchId: branchId,
          workDate: data['work_date'] as String?,
        ));
      }

      return requests;
    });
  }

  Future<void> approveRequest(String scheduleId) async {
    await _db.collection('schedules').doc(scheduleId).update({
      'status': 'approved',
    });
  }

  Future<void> rejectRequest(String scheduleId) async {
    await _db.collection('schedules').doc(scheduleId).update({
      'status': 'rejected',
    });
  }

  Future<ShiftHandoverModel?> getHandoverData({
    required String branchId,
    required String userId,
    required String workDate,
  }) async {
    final scheduleQuery = await _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .where('user_id', isEqualTo: userId)
        .where('work_date', isEqualTo: workDate)
        .limit(1)
        .get();

    if (scheduleQuery.docs.isEmpty) return null;

    final scheduleData = scheduleQuery.docs.first.data();
    final shiftId = scheduleData['shift_id'] as String?;

    String shiftName = '';
    String startTime = '';
    String endTime = '';

    if (shiftId != null && shiftId.isNotEmpty) {
      final shiftDoc = await _db.collection('shifts').doc(shiftId).get();
      if (shiftDoc.exists) {
        final shiftData = shiftDoc.data()!;
        shiftName = shiftData['name'] as String? ?? '';
        startTime = shiftData['start_time'] as String? ?? '';
        endTime = shiftData['end_time'] as String? ?? '';
      }
    }

    final userDoc = await _db.collection('users').doc(userId).get();
    final userName = userDoc.data()?['displayName'] as String? ?? '';

    final startOfDay = DateTime.parse(workDate);
    final endOfDay = DateTime(startOfDay.year, startOfDay.month, startOfDay.day, 23, 59, 59);

    final ordersQuery = await _db
        .collection('orders')
        .where('branch_id', isEqualTo: branchId)
        .where('cashier_id', isEqualTo: userId)
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    double systemCash = 0;
    double qrPayment = 0;
    double cardPayment = 0;
    int invoiceCount = 0;

    for (final doc in ordersQuery.docs) {
      final data = doc.data();
      final paymentMethod = data['payment_method'] as String? ?? '';
      final amount = double.tryParse(data['final_amount'] as String? ?? '') ?? 0;

      invoiceCount++;
      switch (paymentMethod) {
        case 'cash':
          systemCash += amount;
          break;
        case 'vietqr':
          qrPayment += amount;
          break;
        case 'card':
          cardPayment += amount;
          break;
      }
    }

    return ShiftHandoverModel(
      shiftId: shiftId ?? '',
      branchId: branchId,
      currentShift: '$shiftName $startTime - $endTime',
      cashier: userName,
      cashierId: userId,
      invoiceCount: invoiceCount,
      systemCash: '${systemCash.toStringAsFixed(0)}đ',
      qrPayment: '${qrPayment.toStringAsFixed(0)}đ',
      cardPayment: '${cardPayment.toStringAsFixed(0)}đ',
      totalRevenue: '${(systemCash + qrPayment + cardPayment).toStringAsFixed(0)}đ',
    );
  }

  Future<void> signHandover({
    required String branchId,
    required String userId,
    required String workDate,
    required double actualCash,
    String? reason,
  }) async {
    final scheduleQuery = await _db
        .collection('schedules')
        .where('branch_id', isEqualTo: branchId)
        .where('user_id', isEqualTo: userId)
        .where('work_date', isEqualTo: workDate)
        .limit(1)
        .get();

    if (scheduleQuery.docs.isNotEmpty) {
      await _db
          .collection('schedules')
          .doc(scheduleQuery.docs.first.id)
          .update({
        'status': 'handed_over',
        'notes': reason ?? 'Bàn giao ca thành công',
      });
    }
  }
}
