import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/branch_dashboard_model.dart';

class BranchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<BranchDashboardModel> getBranchDashboard(String branchId) {
    final ordersQuery = _db
        .collection('orders')
        .where('branch_id', isEqualTo: branchId);

    final usersQuery = _db
        .collection('users')
        .where('branchId', isEqualTo: branchId)
        .where('role', whereIn: ['pharmacist', 'cashier', 'warehouse_staff']);

    return ordersQuery.snapshots().asyncExpand((ordersSnap) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayOrders = ordersSnap.docs.where((doc) {
        final createdAt = (doc.data()['created_at'] as Timestamp?)?.toDate();
        return createdAt != null && createdAt.isAfter(todayStart);
      }).toList();

      double totalRevenue = 0;
      int servingCount = 0;
      for (final doc in todayOrders) {
        final data = doc.data();
        final finalAmountStr = (data['final_amount'] as String?) ?? '';
        totalRevenue += double.tryParse(finalAmountStr) ?? 0;
        if (data['status'] == 'serving') servingCount++;
      }

      final formattedRevenue = _formatRevenue(totalRevenue);

      return usersQuery.snapshots().map((usersSnap) {
        final workingStaff = usersSnap.docs.map((doc) {
          final data = doc.data();
          return WorkingStaffModel(
            name: data['displayName'] as String? ?? '',
            role: _mapRole(data['role'] as String? ?? ''),
            shift: 'Ca hiện tại',
          );
        }).toList();

        return BranchDashboardModel(
          branchId: branchId,
          revenueToday: formattedRevenue,
          invoices: '${todayOrders.length}',
          counterTitle: 'Đang phục vụ tại quầy',
          counterSummary: '$servingCount quầy đang mở',
          waitingCustomers: '$servingCount khách đang chờ phục vụ',
          workingStaff: workingStaff,
        );
      });
    });
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
