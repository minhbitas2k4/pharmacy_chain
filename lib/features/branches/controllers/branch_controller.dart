import 'package:flutter/foundation.dart';

import '../models/branch_dashboard_model.dart';
import '../services/branch_service.dart';

class BranchController extends ChangeNotifier {
  BranchController({BranchService? branchService})
    : _branchService = branchService ?? BranchService();

  final BranchService _branchService;
  bool _isLoading = false;
  BranchDashboardModel? _dashboard;

  bool get isLoading => _isLoading;
  BranchDashboardModel? get dashboard => _dashboard;

  Future<void> loadDashboard() async {
    _setLoading(true);
    try {
      _dashboard = await _branchService.fetchBranchDashboard();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
