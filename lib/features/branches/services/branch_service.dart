import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/branch_dashboard_model.dart';

enum DashboardPeriod { day, week, month }

class BranchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<BranchDashboardModel> getBranchDashboard({
    required String branchId,
    required DashboardPeriod period,
    required DateTime selectedDate,
    String? counterFilter,
  }) {
    final range = _getDateRange(period, selectedDate);

    final todayStr =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    final controller = StreamController<BranchDashboardModel>();

    _listenToDashboard(
      controller: controller,
      branchId: branchId,
      range: range,
      todayStr: todayStr,
      counterFilter: counterFilter,
      period: period,
      selectedDate: selectedDate,
    );

    return controller.stream;
  }

  Future<void> _listenToDashboard({
    required StreamController<BranchDashboardModel> controller,
    required String branchId,
    required ({DateTime start, DateTime end}) range,
    required String todayStr,
    required String? counterFilter,
    required DashboardPeriod period,
    required DateTime selectedDate,
  }) async {
    await for (final ordersSnap in _db
        .collection('orders')
        .where('branch_id', isEqualTo: branchId)
        .snapshots()) {
      final productsSnap = await _db.collection('products').get();

      final Map<String, String> productCounterMap = {};
      final Set<String> counters = {};
      for (final doc in productsSnap.docs) {
        final data = doc.data();
        final location = data['shift_location'] as String? ?? '';
        if (location.isNotEmpty) {
          productCounterMap[doc.id] = location;
          counters.add(location);
        }
      }

      double totalRevenue = 0;
      int servingCount = 0;
      int totalOrderCount = 0;

      final Map<String, double> counterRevenueMap = {};
      final Map<String, int> counterInvoiceMap = {};

      for (final doc in ordersSnap.docs) {
        final data = doc.data();
        final createdAt = data['created_at'] as Timestamp?;
        if (createdAt != null) {
          final date = createdAt.toDate();
          if (date.isBefore(range.start) || date.isAfter(range.end)) {
            continue;
          }
        }

        final finalAmountStr = (data['final_amount'] as String?) ?? '';
        final amount = double.tryParse(finalAmountStr) ?? 0;
        if (data['status'] == 'serving') servingCount++;
        totalOrderCount++;

        final items = data['items'] as List<dynamic>?;
        final Set<String> orderCounters = {};
        if (items != null) {
          for (final item in items) {
            final productId = item['product_id'] as String? ?? '';
            final c = productCounterMap[productId];
            if (c != null) orderCounters.add(c);
          }
        }

        bool matchesFilter = true;
        if (counterFilter != null && counterFilter.isNotEmpty) {
          matchesFilter = orderCounters.contains(counterFilter);
        }

        if (matchesFilter) {
          totalRevenue += amount;
          for (final c in orderCounters) {
            counterRevenueMap[c] = (counterRevenueMap[c] ?? 0) + amount;
            counterInvoiceMap[c] = (counterInvoiceMap[c] ?? 0) + 1;
          }
          if (orderCounters.isEmpty &&
              (counterFilter == null || counterFilter.isEmpty)) {
            counterRevenueMap['Khác'] =
                (counterRevenueMap['Khác'] ?? 0) + amount;
            counterInvoiceMap['Khác'] =
                (counterInvoiceMap['Khác'] ?? 0) + 1;
          }
        }
      }

      final formattedRevenue = _formatRevenue(totalRevenue);
      final counterRevenueList = counterRevenueMap.entries.map((e) {
        return CounterRevenueModel(
          counter: e.key,
          revenue: _formatRevenue(e.value),
          invoiceCount: counterInvoiceMap[e.key] ?? 0,
        );
      }).toList()
        ..sort((a, b) => b.invoiceCount.compareTo(a.invoiceCount));

      final usersSnap = await _db
          .collection('users')
          .where('branchId', isEqualTo: branchId)
          .get();

      final activeStaffIds = <String>{};
      final staffRoles = <String, String>{};
      final staffNames = <String, String>{};

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final role = data['role'] as String? ?? '';
        if (role == 'pharmacist' ||
            role == 'cashier' ||
            role == 'warehouse_staff') {
          activeStaffIds.add(doc.id);
          staffRoles[doc.id] = role;
          staffNames[doc.id] = data['displayName'] as String? ?? '';
        }
      }

      final schedulesSnap = await _db
          .collection('schedules')
          .where('branch_id', isEqualTo: branchId)
          .get();

      final Map<String, String> userShiftMap = {};

      for (final doc in schedulesSnap.docs) {
        final data = doc.data();
        final userId = data['user_id'] as String? ?? '';
        final workDate = data['work_date'] as String? ?? '';
        final status = data['status'] as String? ?? '';
        final shiftId = data['shift_id'] as String? ?? '';

        if (userId.isNotEmpty && workDate == todayStr && status == 'active') {
          userShiftMap[userId] = shiftId;
        }
      }

      final shiftIds = userShiftMap.values.toSet();
      final Map<String, Map<String, String>> shiftDetailsMap = {};
      for (final sid in shiftIds) {
        if (sid.isEmpty) continue;
        final shiftDoc = await _db.collection('shifts').doc(sid).get();
        if (shiftDoc.exists) {
          final sd = shiftDoc.data()!;
          shiftDetailsMap[sid] = {
            'name': sd['name'] as String? ?? '',
            'start_time': sd['start_time'] as String? ?? '',
            'end_time': sd['end_time'] as String? ?? '',
          };
        }
      }

      final workingStaff = <WorkingStaffModel>[];
      for (final uid in activeStaffIds) {
        final role = staffRoles[uid] ?? '';
        final name = staffNames[uid] ?? '';
        final shiftId = userShiftMap[uid] ?? '';
        final shiftDetail = shiftDetailsMap[shiftId];
        final shiftName = shiftDetail?['name'] ?? '';
        final startTime = shiftDetail?['start_time'] ?? '';
        final endTime = shiftDetail?['end_time'] ?? '';
        final shiftDisplay = shiftName.isNotEmpty
            ? '$shiftName ($startTime - $endTime)'
            : 'Chưa phân ca';

        workingStaff.add(WorkingStaffModel(
          name: name,
          role: _mapRole(role),
          shift: shiftDisplay,
        ));
      }

      final periodLabel = _getPeriodLabel(period, selectedDate);

      if (!controller.isClosed) {
        controller.add(BranchDashboardModel(
          branchId: branchId,
          revenueToday: formattedRevenue,
          invoices: '$totalOrderCount',
          counterTitle: 'Đang phục vụ tại quầy',
          counterSummary: '$servingCount quầy đang mở',
          waitingCustomers: '$servingCount khách đang chờ phục vụ',
          workingStaff: workingStaff,
          periodLabel: periodLabel,
          availableCounters: counters.toList()..sort(),
          selectedCounter: counterFilter,
          counterRevenue: counterRevenueList,
        ));
      }
    }
  }

  ({DateTime start, DateTime end}) _getDateRange(
    DashboardPeriod period,
    DateTime date,
  ) {
    switch (period) {
      case DashboardPeriod.day:
        final start = DateTime(date.year, date.month, date.day);
        final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
        return (start: start, end: end);

      case DashboardPeriod.week:
        final weekday = date.weekday;
        final start = date.subtract(Duration(days: weekday - 1));
        final startOfDay = DateTime(start.year, start.month, start.day);
        final endOfDay = startOfDay.add(const Duration(days: 7, seconds: -1));
        return (start: startOfDay, end: endOfDay);

      case DashboardPeriod.month:
        final start = DateTime(date.year, date.month, 1);
        final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
        return (start: start, end: end);
    }
  }

  String _getPeriodLabel(DashboardPeriod period, DateTime date) {
    final months = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];

    switch (period) {
      case DashboardPeriod.day:
        return '${date.day}/${date.month}/${date.year}';

      case DashboardPeriod.week:
        final start = date.subtract(Duration(days: date.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return 'Tuần ${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}';

      case DashboardPeriod.month:
        return '${months[date.month]} ${date.year}';
    }
  }

  String _formatRevenue(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _mapRole(String role) {
    switch (role) {
      case 'pharmacist':
        return 'Dược sĩ';
      case 'cashier':
        return 'Thu ngân';
      case 'warehouse_staff':
        return 'Kho';
      case 'branch_manager':
        return 'Quản lý CN';
      default:
        return role;
    }
  }
}
