import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/branch_dashboard_model.dart';
import '../services/branch_service.dart';

class BranchController extends ChangeNotifier {
  BranchController({required this.branchId, BranchService? branchService})
    : _branchService = branchService ?? BranchService();

  final String branchId;
  final BranchService _branchService;
  bool _isLoading = false;
  BranchDashboardModel? _dashboard;
  String? _errorMessage;
  StreamSubscription<BranchDashboardModel>? _subscription;

  bool get isLoading => _isLoading;
  BranchDashboardModel? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;

  void loadDashboard() {
    _setLoading(true);
    _subscription?.cancel();
    _subscription = _branchService.getBranchDashboard(branchId).listen(
      (dashboard) {
        _dashboard = dashboard;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (error) {
        _errorMessage = 'Không thể tải dữ liệu chi nhánh';
        _setLoading(false);
      },
    );
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
