import '../models/branch_dashboard_model.dart';

class BranchService {
  Future<BranchDashboardModel> fetchBranchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    return const BranchDashboardModel(
      revenueToday: '42,1M',
      invoices: '312',
      counterTitle: 'Đang phục vụ tại quầy',
      counterSummary: '3/4 quầy đang mở',
      waitingCustomers: '8 khách đang chờ phục vụ',
      workingStaff: <WorkingStaffModel>[
        WorkingStaffModel(
          name: 'Nguyễn Thị Lan',
          role: 'Dược sĩ',
          shift: 'Ca sáng',
        ),
        WorkingStaffModel(
          name: 'Trần Văn Minh',
          role: 'Thu ngân',
          shift: 'Ca sáng',
        ),
        WorkingStaffModel(name: 'Lê Thị Hoa', role: 'Kho', shift: 'Ca chiều'),
      ],
    );
  }
}
