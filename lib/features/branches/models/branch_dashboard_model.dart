class BranchDashboardModel {
  const BranchDashboardModel({
    required this.branchId,
    required this.revenueToday,
    required this.invoices,
    required this.counterTitle,
    required this.counterSummary,
    required this.waitingCustomers,
    required this.workingStaff,
  });

  final String branchId;
  final String revenueToday;
  final String invoices;
  final String counterTitle;
  final String counterSummary;
  final String waitingCustomers;
  final List<WorkingStaffModel> workingStaff;
}

class WorkingStaffModel {
  const WorkingStaffModel({
    required this.name,
    required this.role,
    required this.shift,
  });

  final String name;
  final String role;
  final String shift;
}
