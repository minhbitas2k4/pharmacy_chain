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

  DashboardPeriod _selectedPeriod = DashboardPeriod.day;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCounter;

  bool get isLoading => _isLoading;
  BranchDashboardModel? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  DashboardPeriod get selectedPeriod => _selectedPeriod;
  DateTime get selectedDate => _selectedDate;
  String? get selectedCounter => _selectedCounter;

  void loadDashboard() {
    _setLoading(true);
    _subscription?.cancel();
    _subscription = _branchService
        .getBranchDashboard(
          branchId: branchId,
          period: _selectedPeriod,
          selectedDate: _selectedDate,
          counterFilter: _selectedCounter,
        )
        .listen(
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

  void setPeriod(DashboardPeriod period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
    loadDashboard();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadDashboard();
  }

  void setCounter(String? counter) {
    _selectedCounter = counter;
    notifyListeners();
    loadDashboard();
  }

  void previousPeriod() {
    switch (_selectedPeriod) {
      case DashboardPeriod.day:
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case DashboardPeriod.week:
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case DashboardPeriod.month:
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          _selectedDate.day,
        );
        break;
    }
    notifyListeners();
    loadDashboard();
  }

  void nextPeriod() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case DashboardPeriod.day:
        final next = _selectedDate.add(const Duration(days: 1));
        if (!next.isAfter(now)) _selectedDate = next;
        break;
      case DashboardPeriod.week:
        final next = _selectedDate.add(const Duration(days: 7));
        if (!next.isAfter(now)) _selectedDate = next;
        break;
      case DashboardPeriod.month:
        final next = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          _selectedDate.day,
        );
        if (!next.isAfter(now)) _selectedDate = next;
        break;
    }
    notifyListeners();
    loadDashboard();
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
