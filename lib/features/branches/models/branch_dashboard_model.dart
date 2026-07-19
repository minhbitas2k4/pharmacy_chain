class BranchDashboardModel {
  const BranchDashboardModel({
    required this.branchId,
    required this.revenueToday,
    required this.invoices,
    required this.counterTitle,
    required this.counterSummary,
    required this.waitingCustomers,
    required this.workingStaff,
    required this.periodLabel,
    this.availableCounters = const [],
    this.selectedCounter,
    this.counterRevenue = const [],
  });

  final String branchId;
  final String revenueToday;
  final String invoices;
  final String counterTitle;
  final String counterSummary;
  final String waitingCustomers;
  final List<WorkingStaffModel> workingStaff;
  final String periodLabel;
  final List<String> availableCounters;
  final String? selectedCounter;
  final List<CounterRevenueModel> counterRevenue;
}

class WorkingStaffModel {
  const WorkingStaffModel({
    required this.name,
    required this.role,
    required this.shift,
    this.counter = '',
  });

  final String name;
  final String role;
  final String shift;
  final String counter;
}

class CounterRevenueModel {
  const CounterRevenueModel({
    required this.counter,
    required this.revenue,
    required this.invoiceCount,
  });

  final String counter;
  final String revenue;
  final int invoiceCount;
}
